-- Triggers and Functions for Legibris Automation
-- Handles database automation (streaks, statistics, goals, social activities, achievements).

-- 1. PROFILE CREATION ON SIGNUP
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, full_name, avatar_url, is_premium)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', 'lector_' || substring(new.id::text from 1 for 8)),
    coalesce(new.raw_user_meta_data->>'full_name', 'Lector de Legibris'),
    new.raw_user_meta_data->>'avatar_url',
    false
  );
  
  -- Initialize reading streak
  insert into public.reading_streaks (user_id, current_streak, longest_streak, last_reading_date)
  values (new.id, 0, 0, null);
  
  return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


-- 2. UPDATED_AT TRIGGER FUNCTION
create or replace function public.update_updated_at_column()
returns trigger as $$
begin
    new.updated_at = timezone('utc'::text, now());
    return new;
end;
$$ language plpgsql;

create or replace trigger set_profiles_updated_at
    before update on public.profiles
    for each row execute procedure public.update_updated_at_column();

create or replace trigger set_user_books_updated_at
    before update on public.user_books
    for each row execute procedure public.update_updated_at_column();

create or replace trigger set_collections_updated_at
    before update on public.collections
    for each row execute procedure public.update_updated_at_column();

create or replace trigger set_reviews_updated_at
    before update on public.reviews
    for each row execute procedure public.update_updated_at_column();

create or replace trigger set_reading_goals_updated_at
    before update on public.reading_goals
    for each row execute procedure public.update_updated_at_column();


-- 3. AUTOMATIC STREAK UPDATE ON READING SESSION INSERTION
create or replace function public.update_user_reading_streak()
returns trigger as $$
declare
    streak_record record;
    date_diff integer;
begin
    select * into streak_record from public.reading_streaks where user_id = new.user_id;
    
    if streak_record.last_reading_date is null then
        -- First reading session ever
        update public.reading_streaks
        set current_streak = 1,
            longest_streak = 1,
            last_reading_date = new.session_date,
            updated_at = now()
        where user_id = new.user_id;
    else
        date_diff := new.session_date - streak_record.last_reading_date;
        
        if date_diff = 1 then
            -- Read the next consecutive day: increment streak
            update public.reading_streaks
            set current_streak = current_streak + 1,
                longest_streak = greatest(longest_streak, current_streak + 1),
                last_reading_date = new.session_date,
                updated_at = now()
            where user_id = new.user_id;
        elsif date_diff > 1 then
            -- Gaps: Reset current streak to 1
            update public.reading_streaks
            set current_streak = 1,
                longest_streak = greatest(longest_streak, 1),
                last_reading_date = new.session_date,
                updated_at = now()
            where user_id = new.user_id;
        -- If date_diff is 0, they read today already, streak remains unchanged.
        end if;
    end if;
    
    return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_reading_session_logged
    after insert on public.reading_sessions
    for each row execute procedure public.update_user_reading_streak();


-- 4. UPDATE READING GOALS PROGRESS ON NEW READING SESSIONS
create or replace function public.update_reading_goals_progress()
returns trigger as $$
declare
    session_year integer;
    session_month integer;
begin
    session_year := extract(year from new.session_date)::integer;
    session_month := extract(month from new.session_date)::integer;

    -- Update pages progress
    update public.reading_goals
    set current_value = current_value + new.pages_read,
        updated_at = now()
    where user_id = new.user_id
      and metric = 'paginas'
      and year = session_year
      and (period = 'anual' or (period = 'mensual' and month = session_month));

    -- Update minutes progress
    update public.reading_goals
    set current_value = current_value + new.duration_minutes,
        updated_at = now()
    where user_id = new.user_id
      and metric = 'minutos'
      and year = session_year
      and (period = 'anual' or (period = 'mensual' and month = session_month));

    return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_reading_session_added_for_goals
    after insert on public.reading_sessions
    for each row execute procedure public.update_reading_goals_progress();


-- 5. UPDATE BOOKS READ GOAL PROGRESS ON BOOK COMPLETED (USER_BOOKS STATUS = 'leido')
create or replace function public.update_books_read_goals()
returns trigger as $$
declare
    finished_year integer;
    finished_month integer;
begin
    if new.status = 'leido' and (old.status is null or old.status <> 'leido') then
        finished_year := extract(year from coalesce(new.end_date, now()))::integer;
        finished_month := extract(month from coalesce(new.end_date, now()))::integer;

        update public.reading_goals
        set current_value = current_value + 1,
            updated_at = now()
        where user_id = new.user_id
          and metric = 'libros'
          and year = finished_year
          and (period = 'anual' or (period = 'mensual' and month = finished_month));
          
        -- Check and assign achievements dynamically
        perform public.check_user_achievements(new.user_id);
    end if;
    return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_book_marked_read
    after update on public.user_books
    for each row execute procedure public.update_books_read_goals();


-- 6. DYNAMIC ACHIEVEMENT SYSTEM CHECK
create or replace function public.check_user_achievements(target_user_id uuid)
returns void as $$
declare
    read_books_count integer;
    longest_streak_days integer;
    achievement_record record;
    already_earned boolean;
begin
    -- Count total books finished
    select count(*) into read_books_count
    from public.user_books
    where user_id = target_user_id and status = 'leido';

    -- Find longest reading streak
    select longest_streak into longest_streak_days
    from public.reading_streaks
    where user_id = target_user_id;

    -- Check all achievements in catalog
    for achievement_record in select * from public.achievements loop
        already_earned := exists(
            select 1 from public.user_achievements
            where user_id = target_user_id and achievement_id = achievement_record.id
        );

        if not already_earned then
            if achievement_record.criteria_type = 'books_count' and read_books_count >= achievement_record.criteria_value then
                insert into public.user_achievements (user_id, achievement_id)
                values (target_user_id, achievement_record.id);
                
                -- Trigger system notification
                insert into public.notifications (user_id, type, title, body, referenced_id)
                values (
                    target_user_id,
                    'achievement',
                    '¡Logro Desbloqueado! 🏆',
                    'Has conseguido el logro: ' || achievement_record.title || '. ' || achievement_record.description,
                    achievement_record.id
                );
            elsif achievement_record.criteria_type = 'streak_days' and longest_streak_days >= achievement_record.criteria_value then
                insert into public.user_achievements (user_id, achievement_id)
                values (target_user_id, achievement_record.id);
                
                -- Trigger system notification
                insert into public.notifications (user_id, type, title, body, referenced_id)
                values (
                    target_user_id,
                    'achievement',
                    '¡Logro Desbloqueado! 🏆',
                    'Has conseguido el logro: ' || achievement_record.title || '. ' || achievement_record.description,
                    achievement_record.id
                );
            end if;
        end if;
    end loop;
end;
$$ language plpgsql security definer;


-- 7. SOCIAL ACTIVITY FEED LOGGER
create or replace function public.log_user_activity()
returns trigger as $$
begin
    if tg_table_name = 'user_books' then
        if new.status = 'leyendo' and (old.status is null or old.status <> 'leyendo') then
            insert into public.activities (user_id, activity_type, target_id)
            values (new.user_id, 'start_reading', new.book_id);
        elsif new.status = 'leido' and (old.status is null or old.status <> 'leido') then
            insert into public.activities (user_id, activity_type, target_id)
            values (new.user_id, 'finish_reading', new.book_id);
        end if;
    elsif tg_table_name = 'reviews' then
        insert into public.activities (user_id, activity_type, target_id)
        values (new.user_id, 'write_review', new.id);
    elsif tg_table_name = 'followers' then
        insert into public.activities (user_id, activity_type, target_id)
        values (new.follower_id, 'follow', new.followed_id);
        
        -- Create follow notification
        insert into public.notifications (user_id, notifier_id, type, title, body, referenced_id)
        values (
            new.followed_id,
            new.follower_id,
            'follow',
            'Nuevo seguidor',
            'Comenzó a seguirte en Legibris.',
            new.follower_id
        );
    end if;
    return new;
end;
$$ language plpgsql security definer;

create or replace trigger log_book_activity
    after update or insert on public.user_books
    for each row execute procedure public.log_user_activity();

create or replace trigger log_review_activity
    after insert on public.reviews
    for each row execute procedure public.log_user_activity();

create or replace trigger log_follow_activity
    after insert on public.followers
    for each row execute procedure public.log_user_activity();
