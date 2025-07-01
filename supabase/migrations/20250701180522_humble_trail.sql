/*
  # Initial Schema for Findie App - Fixed Version

  1. New Tables
    - `users`
      - `id` (uuid, primary key) - matches auth.users id
      - `email` (text, unique)
      - `name` (text)
      - `avatar_url` (text, nullable)
      - `is_verified` (boolean, default false)
      - `created_at` (timestamp)
      - `metadata` (jsonb, nullable)

    - `posts`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to users)
      - `title` (text)
      - `description` (text)
      - `category` (text)
      - `building` (text)
      - `image_urls` (text array)
      - `ocr_text` (text, nullable)
      - `is_found` (boolean) - true for found items, false for lost items
      - `expires_at` (timestamp)
      - `created_at` (timestamp)
      - `tags` (text array)
      - `metadata` (jsonb, nullable)

    - `messages`
      - `id` (uuid, primary key)
      - `from_user_id` (uuid, foreign key to users)
      - `to_user_id` (uuid, foreign key to users)
      - `post_id` (uuid, foreign key to posts)
      - `message` (text)
      - `timestamp` (timestamp)
      - `is_read` (boolean, default false)

    - `verifications`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to users)
      - `id_image_url` (text)
      - `extracted_name` (text, nullable)
      - `extracted_dob` (text, nullable)
      - `status` (text, default 'pending') - pending, approved, rejected
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
    - Add policies for public read access where appropriate
*/

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text UNIQUE NOT NULL,
  name text,
  avatar_url text,
  is_verified boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  metadata jsonb
);

-- Create posts table
CREATE TABLE IF NOT EXISTS posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  category text NOT NULL,
  building text NOT NULL,
  image_urls text[] DEFAULT '{}',
  ocr_text text,
  is_found boolean NOT NULL,
  expires_at timestamptz NOT NULL,
  created_at timestamptz DEFAULT now(),
  tags text[] DEFAULT '{}',
  metadata jsonb
);

-- Create messages table
CREATE TABLE IF NOT EXISTS messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  from_user_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  to_user_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  post_id uuid REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
  message text NOT NULL,
  timestamp timestamptz DEFAULT now(),
  is_read boolean DEFAULT false
);

-- Create verifications table
CREATE TABLE IF NOT EXISTS verifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  id_image_url text NOT NULL,
  extracted_name text,
  extracted_dob text,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security (only if not already enabled)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE tablename = 'users' 
    AND rowsecurity = true
  ) THEN
    ALTER TABLE users ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE tablename = 'posts' 
    AND rowsecurity = true
  ) THEN
    ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE tablename = 'messages' 
    AND rowsecurity = true
  ) THEN
    ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE tablename = 'verifications' 
    AND rowsecurity = true
  ) THEN
    ALTER TABLE verifications ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

-- Drop existing policies if they exist and recreate them
DO $$ 
BEGIN
  -- Users policies
  DROP POLICY IF EXISTS "Users can read all profiles" ON users;
  CREATE POLICY "Users can read all profiles"
    ON users
    FOR SELECT
    TO authenticated
    USING (true);

  DROP POLICY IF EXISTS "Users can update own profile" ON users;
  CREATE POLICY "Users can update own profile"
    ON users
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = id);

  DROP POLICY IF EXISTS "Users can insert own profile" ON users;
  CREATE POLICY "Users can insert own profile"
    ON users
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = id);

  -- Posts policies
  DROP POLICY IF EXISTS "Anyone can read posts" ON posts;
  CREATE POLICY "Anyone can read posts"
    ON posts
    FOR SELECT
    TO anon, authenticated
    USING (true);

  DROP POLICY IF EXISTS "Authenticated users can create posts" ON posts;
  CREATE POLICY "Authenticated users can create posts"
    ON posts
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

  DROP POLICY IF EXISTS "Users can update own posts" ON posts;
  CREATE POLICY "Users can update own posts"
    ON posts
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id);

  DROP POLICY IF EXISTS "Users can delete own posts" ON posts;
  CREATE POLICY "Users can delete own posts"
    ON posts
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

  -- Messages policies
  DROP POLICY IF EXISTS "Users can read messages they're involved in" ON messages;
  CREATE POLICY "Users can read messages they're involved in"
    ON messages
    FOR SELECT
    TO authenticated
    USING (auth.uid() = from_user_id OR auth.uid() = to_user_id);

  DROP POLICY IF EXISTS "Authenticated users can send messages" ON messages;
  CREATE POLICY "Authenticated users can send messages"
    ON messages
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = from_user_id);

  DROP POLICY IF EXISTS "Users can update messages they sent" ON messages;
  CREATE POLICY "Users can update messages they sent"
    ON messages
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = from_user_id);

  -- Verifications policies
  DROP POLICY IF EXISTS "Users can read own verifications" ON verifications;
  CREATE POLICY "Users can read own verifications"
    ON verifications
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

  DROP POLICY IF EXISTS "Users can create own verifications" ON verifications;
  CREATE POLICY "Users can create own verifications"
    ON verifications
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);
END $$;

-- Create indexes for better performance (only if they don't exist)
CREATE INDEX IF NOT EXISTS posts_user_id_idx ON posts(user_id);
CREATE INDEX IF NOT EXISTS posts_category_idx ON posts(category);
CREATE INDEX IF NOT EXISTS posts_building_idx ON posts(building);
CREATE INDEX IF NOT EXISTS posts_is_found_idx ON posts(is_found);
CREATE INDEX IF NOT EXISTS posts_created_at_idx ON posts(created_at DESC);
CREATE INDEX IF NOT EXISTS posts_expires_at_idx ON posts(expires_at);

-- Full-text search index for posts
CREATE INDEX IF NOT EXISTS posts_search_idx ON posts 
USING gin(to_tsvector('english', title || ' ' || description || ' ' || COALESCE(ocr_text, '')));

CREATE INDEX IF NOT EXISTS messages_post_id_idx ON messages(post_id);
CREATE INDEX IF NOT EXISTS messages_from_user_id_idx ON messages(from_user_id);
CREATE INDEX IF NOT EXISTS messages_to_user_id_idx ON messages(to_user_id);
CREATE INDEX IF NOT EXISTS messages_timestamp_idx ON messages(timestamp DESC);

-- Create storage buckets (only if they don't exist)
INSERT INTO storage.buckets (id, name, public) 
VALUES 
  ('post-images', 'post-images', true),
  ('avatars', 'avatars', true),
  ('verification-docs', 'verification-docs', false)
ON CONFLICT (id) DO NOTHING;

-- Storage policies (drop and recreate to avoid conflicts)
DO $$ 
BEGIN
  -- Storage policies for post images
  DROP POLICY IF EXISTS "Anyone can view post images" ON storage.objects;
  CREATE POLICY "Anyone can view post images"
    ON storage.objects
    FOR SELECT
    USING (bucket_id = 'post-images');

  DROP POLICY IF EXISTS "Authenticated users can upload post images" ON storage.objects;
  CREATE POLICY "Authenticated users can upload post images"
    ON storage.objects
    FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'post-images');

  DROP POLICY IF EXISTS "Users can update own post images" ON storage.objects;
  CREATE POLICY "Users can update own post images"
    ON storage.objects
    FOR UPDATE
    TO authenticated
    USING (bucket_id = 'post-images' AND auth.uid()::text = (storage.foldername(name))[1]);

  DROP POLICY IF EXISTS "Users can delete own post images" ON storage.objects;
  CREATE POLICY "Users can delete own post images"
    ON storage.objects
    FOR DELETE
    TO authenticated
    USING (bucket_id = 'post-images' AND auth.uid()::text = (storage.foldername(name))[1]);

  -- Storage policies for avatars
  DROP POLICY IF EXISTS "Anyone can view avatars" ON storage.objects;
  CREATE POLICY "Anyone can view avatars"
    ON storage.objects
    FOR SELECT
    USING (bucket_id = 'avatars');

  DROP POLICY IF EXISTS "Authenticated users can upload avatars" ON storage.objects;
  CREATE POLICY "Authenticated users can upload avatars"
    ON storage.objects
    FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'avatars');

  DROP POLICY IF EXISTS "Users can update own avatars" ON storage.objects;
  CREATE POLICY "Users can update own avatars"
    ON storage.objects
    FOR UPDATE
    TO authenticated
    USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

  -- Storage policies for verification documents
  DROP POLICY IF EXISTS "Users can view own verification docs" ON storage.objects;
  CREATE POLICY "Users can view own verification docs"
    ON storage.objects
    FOR SELECT
    TO authenticated
    USING (bucket_id = 'verification-docs' AND auth.uid()::text = (storage.foldername(name))[1]);

  DROP POLICY IF EXISTS "Users can upload own verification docs" ON storage.objects;
  CREATE POLICY "Users can upload own verification docs"
    ON storage.objects
    FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'verification-docs');
END $$;