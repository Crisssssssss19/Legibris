-- Legibris Database Schema (Production Ready)
-- Designed for Supabase / PostgreSQL
-- Focuses on high-performance indexing, foreign keys constraints, and data integrity.

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. USERS PROFILE MAPPING
create table public.profiles (
    id uuid references auth.users on delete cascade primary key,
    username text unique not null,
    full_name text,
    avatar_url text,
    bio text,
    website text,
    is_premium boolean default false,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
    
    constraint username_length check (char_length(username) >= 3)
);

-- 2. AUTHORS
create table public.authors (
    id uuid default uuid_generate_v4() primary key,
    name text not null unique,
    bio text,
    avatar_url text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. GENRES
create table public.genres (
    id uuid default uuid_generate_v4() primary key,
    name text not null unique,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 4. BOOKS
create table public.books (
    id uuid default uuid_generate_v4() primary key,
    google_books_id text unique,
    isbn10 text unique,
    isbn13 text unique,
    title text not null,
    subtitle text,
    description text,
    publisher text,
    published_date date,
    page_count integer,
    cover_url text,
    language text,
    average_rating numeric(3, 2) default 0.0,
    ratings_count integer default 0,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Join table for Books and Authors (Many-to-Many)
create table public.book_authors (
    book_id uuid references public.books(id) on delete cascade,
    author_id uuid references public.authors(id) on delete cascade,
    primary key (book_id, author_id)
);

-- Join table for Books and Genres (Many-to-Many)
create table public.book_genres (
    book_id uuid references public.books(id) on delete cascade,
    genre_id uuid references public.genres(id) on delete cascade,
    primary key (book_id, genre_id)
);

-- 5. USER BOOKS (LIBRARY RELATIONSHIPS)
create type reading_status as enum ('leyendo', 'leido', 'pendiente', 'favorito', 'abandonado', 'releyendo');

create table public.user_books (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.profiles(id) on delete cascade not null,
    book_id uuid references public.books(id) on delete cascade not null,
    status reading_status not null default 'pendiente',
    is_favorite boolean default false not null,
    rating integer check (rating >= 1 and rating <= 5),
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    personal_notes text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
    
    unique(user_id, book_id)
);

-- 6. READING SESSIONS & LOGS
create table public.reading_sessions (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.profiles(id) on delete cascade not null,
    book_id uuid references public.books(id) on delete cascade not null,
    duration_minutes integer not null check (duration_minutes >= 0),
    pages_read integer not null check (pages_read >= 0),
    start_page integer,
    end_page integer,
    session_date date default current_date not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table public.reading_logs (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.profiles(id) on delete cascade not null,
    book_id uuid references public.books(id) on delete cascade not null,
    note text,
    progress_percentage numeric(5, 2) check (progress_percentage >= 0.00 and progress_percentage <= 100.00),
    logged_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 7. BOOKSHELVES & COLLECTIONS
create table public.bookshelves (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.profiles(id) on delete cascade not null,
    name text not null,
    description text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table public.collections (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.profiles(id) on delete cascade not null,
    bookshelf_id uuid references public.bookshelves(id) on delete cascade, -- Optional parent bookshelf
    name text not null,
    description text,
    is_private boolean default false not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table public.collection_books (
    collection_id uuid references public.collections(id) on delete cascade not null,
    book_id uuid references public.books(id) on delete cascade not null,
    added_at timestamp with time zone default timezone('utc'::text, now()) not null,
    primary key (collection_id, book_id)
);

-- 8. REVIEWS & SOCIAL
create table public.reviews (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.profiles(id) on delete cascade not null,
    book_id uuid references public.books(id) on delete cascade not null,
    rating integer not null check (rating >= 1 and rating <= 5),
    content text not null,
    contains_spoilers boolean default false not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
    
    unique(user_id, book_id)
);

create table public.review_comments (
    id uuid default uuid_generate_v4() primary key,
    review_id uuid references public.reviews(id) on delete cascade not null,
    user_id uuid references public.profiles(id) on delete cascade not null,
    content text not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table public.review_likes (
    review_id uuid references public.reviews(id) on delete cascade not null,
    user_id uuid references public.profiles(id) on delete cascade not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    primary key (review_id, user_id)
);

create table public.followers (
    follower_id uuid references public.profiles(id) on delete cascade not null,
    followed_id uuid references public.profiles(id) on delete cascade not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    primary key (follower_id, followed_id),
    constraint self_follow_prevent check (follower_id <> followed_id)
);

create table public.activities (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.profiles(id) on delete cascade not null,
    activity_type text not null, -- 'start_reading', 'finish_reading', 'write_review', 'like_review', 'follow'
    target_id uuid not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 9. GOALS & STREAKS
create table public.goals (
    id uuid default uuid_generate_v4() primary key,
    title text not null,
    description text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create type goal_period as enum ('diario', 'mensual', 'anual');
create type goal_metric as enum ('libros', 'paginas', 'minutos');

create table public.reading_goals (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.profiles(id) on delete cascade not null,
    metric goal_metric not null,
    target_value integer not null check (target_value > 0),
    current_value integer default 0 not null,
    period goal_period not null,
    year integer not null,
    month integer,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table public.reading_streaks (
    user_id uuid references public.profiles(id) on delete cascade primary key,
    current_streak integer default 0 not null check (current_streak >= 0),
    longest_streak integer default 0 not null check (longest_streak >= 0),
    last_reading_date date,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 10. GAMIFICATION (ACHIEVEMENTS)
create table public.achievement_types (
    id uuid default uuid_generate_v4() primary key,
    name text not null unique,
    description text not null,
    criteria_type text not null,
    criteria_value integer not null
);

create table public.achievements (
    id uuid default uuid_generate_v4() primary key,
    type_id uuid references public.achievement_types(id) on delete cascade not null,
    title text not null unique,
    badge_url text not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table public.user_achievements (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.profiles(id) on delete cascade not null,
    achievement_id uuid references public.achievements(id) on delete cascade not null,
    unlocked_at timestamp with time zone default timezone('utc'::text, now()) not null,
    
    unique(user_id, achievement_id)
);

-- 11. NOTIFICATIONS
create table public.notifications (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.profiles(id) on delete cascade not null,
    notifier_id uuid references public.profiles(id) on delete cascade,
    type text not null,
    title text not null,
    body text not null,
    is_read boolean default false not null,
    referenced_id uuid,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 12. NOTES, QUOTES & BOOKMARKS
create table public.book_quotes (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.profiles(id) on delete cascade not null,
    book_id uuid references public.books(id) on delete cascade not null,
    quote_text text not null,
    page_number integer,
    is_public boolean default true not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table public.book_notes (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.profiles(id) on delete cascade not null,
    book_id uuid references public.books(id) on delete cascade not null,
    note_text text not null,
    page_number integer,
    is_spoilers boolean default false not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table public.bookmarks (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.profiles(id) on delete cascade not null,
    book_id uuid references public.books(id) on delete cascade not null,
    page_number integer not null,
    note text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 13. USER PREFERENCES, CACHE & SEARCH
create table public.search_history (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.profiles(id) on delete cascade not null,
    query text not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table public.user_preferences (
    user_id uuid references public.profiles(id) on delete cascade primary key,
    dark_mode boolean default false not null,
    genres_favorites jsonb default '[]'::jsonb,
    push_enabled boolean default true not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table public.books_cache (
    id uuid default uuid_generate_v4() primary key,
    query_key text unique not null,
    raw_response jsonb not null,
    cached_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table public.book_recommendations (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.profiles(id) on delete cascade not null,
    book_id uuid references public.books(id) on delete cascade not null,
    score numeric(3, 2) not null,
    reason text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- INDEXES
create index idx_books_title on public.books(title);
create index idx_user_books_user_status on public.user_books(user_id, status);
create index idx_reading_sessions_user_date on public.reading_sessions(user_id, session_date);
create index idx_reading_logs_user_book on public.reading_logs(user_id, book_id);
create index idx_reviews_book_id on public.reviews(book_id);
create index idx_followers_followed_id on public.followers(followed_id);
create index idx_activities_user_id on public.activities(user_id);
create index idx_notifications_user_read on public.notifications(user_id, is_read);
create index idx_bookmarks_user_book on public.bookmarks(user_id, book_id);
create index idx_books_cache_key on public.books_cache(query_key);
