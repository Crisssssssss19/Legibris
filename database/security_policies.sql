-- Row Level Security (RLS) Policies for Legibris
-- Enforces data security at the database layer.

-- Enable RLS on all tables
alter table public.profiles enable row level security;
alter table public.books enable row level security;
alter table public.authors enable row level security;
alter table public.genres enable row level security;
alter table public.book_authors enable row level security;
alter table public.book_genres enable row level security;
alter table public.user_books enable row level security;
alter table public.reading_sessions enable row level security;
alter table public.reading_logs enable row level security;
alter table public.bookshelves enable row level security;
alter table public.collections enable row level security;
alter table public.collection_books enable row level security;
alter table public.reviews enable row level security;
alter table public.review_comments enable row level security;
alter table public.review_likes enable row level security;
alter table public.followers enable row level security;
alter table public.activities enable row level security;
alter table public.reading_goals enable row level security;
alter table public.reading_streaks enable row level security;
alter table public.achievement_types enable row level security;
alter table public.achievements enable row level security;
alter table public.user_achievements enable row level security;
alter table public.book_quotes enable row level security;
alter table public.book_notes enable row level security;
alter table public.bookmarks enable row level security;
alter table public.search_history enable row level security;
alter table public.user_preferences enable row level security;
alter table public.books_cache enable row level security;
alter table public.book_recommendations enable row level security;
alter table public.notifications enable row level security;

-- 1. PROFILES
create policy "Allow public read access to profiles"
    on public.profiles for select using (true);

create policy "Allow users to update their own profiles"
    on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);

-- 2. CATALOG TABLES (READ ONLY FOR PUBLIC)
create policy "Allow public read access to books" on public.books for select using (true);
create policy "Allow public read access to authors" on public.authors for select using (true);
create policy "Allow public read access to genres" on public.genres for select using (true);
create policy "Allow public read access to book_authors" on public.book_authors for select using (true);
create policy "Allow public read access to book_genres" on public.book_genres for select using (true);
create policy "Allow public read access to achievement_types" on public.achievement_types for select using (true);
create policy "Allow public read access to achievements" on public.achievements for select using (true);

-- 3. USER BOOKS
create policy "Allow public read access to user_books" on public.user_books for select using (true);
create policy "Allow users to manage their own user_books" on public.user_books for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 4. READING SESSIONS & LOGS (PRIVATE)
create policy "Allow users to manage their own reading sessions" on public.reading_sessions for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Allow users to manage their own reading logs" on public.reading_logs for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 5. BOOKSHELVES & COLLECTIONS
create policy "Allow public read access to bookshelves" on public.bookshelves for select using (true);
create policy "Allow users to manage their own bookshelves" on public.bookshelves for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Allow public read access to collections" on public.collections for select using (not is_private or auth.uid() = user_id);
create policy "Allow users to manage their own collections" on public.collections for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Allow read access to collection_books" on public.collection_books for select using (
    exists (select 1 from public.collections c where c.id = collection_id and (not c.is_private or c.user_id = auth.uid()))
);
create policy "Allow users to manage collection_books" on public.collection_books for all using (
    exists (select 1 from public.collections c where c.id = collection_id and c.user_id = auth.uid())
);

-- 6. REVIEWS & SOCIAL
create policy "Allow public read access to reviews" on public.reviews for select using (true);
create policy "Allow users to manage their own reviews" on public.reviews for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Allow public read access to review_comments" on public.review_comments for select using (true);
create policy "Allow users to manage their own comments" on public.review_comments for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Allow public read access to review_likes" on public.review_likes for select using (true);
create policy "Allow users to toggle review_likes" on public.review_likes for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Allow public read access to followers" on public.followers for select using (true);
create policy "Allow users to manage followers" on public.followers for all using (auth.uid() = follower_id) with check (auth.uid() = follower_id);

create policy "Allow public read access to activities" on public.activities for select using (true);

-- 7. GOALS & STREAKS
create policy "Allow users to manage their own reading goals" on public.reading_goals for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Allow public read access to reading_streaks" on public.reading_streaks for select using (true);
create policy "Allow public read access to user_achievements" on public.user_achievements for select using (true);

-- 8. BOOKMARKS, NOTES & QUOTES
create policy "Allow public read access to quotes" on public.book_quotes for select using (is_public or auth.uid() = user_id);
create policy "Allow users to manage their own book_quotes" on public.book_quotes for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Allow users to manage their own book_notes" on public.book_notes for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Allow users to manage their own bookmarks" on public.bookmarks for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 9. PREFERENCES, RECOMMENDATIONS & SEARCH HISTORY
create policy "Allow users to manage their own search_history" on public.search_history for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Allow users to manage their own preferences" on public.user_preferences for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Allow users to view their own recommendations" on public.book_recommendations for select using (auth.uid() = user_id);

-- Cache read is public
create policy "Allow public read access to cache" on public.books_cache for select using (true);

-- 10. NOTIFICATIONS
create policy "Allow users to manage their notifications" on public.notifications for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
