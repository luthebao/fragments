-- Create family_members table
CREATE TABLE IF NOT EXISTS family_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  birth_date DATE,
  death_date DATE,
  age INTEGER,
  gender TEXT,
  occupation TEXT,
  hobbies TEXT[],
  bio TEXT,
  profile_photo_url TEXT,
  extracted_data_json JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create family_relationships table
CREATE TABLE IF NOT EXISTS family_relationships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  person_a_id UUID NOT NULL REFERENCES family_members(id) ON DELETE CASCADE,
  person_b_id UUID NOT NULL REFERENCES family_members(id) ON DELETE CASCADE,
  relationship_type TEXT NOT NULL CHECK (relationship_type IN ('parent', 'child', 'spouse', 'sibling', 'grandparent', 'grandchild', 'cousin', 'uncle', 'aunt', 'niece', 'nephew')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT different_people CHECK (person_a_id != person_b_id)
);

-- Create family_stories table
CREATE TABLE IF NOT EXISTS family_stories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  family_member_id UUID REFERENCES family_members(id) ON DELETE SET NULL,
  story_text TEXT NOT NULL,
  ai_extraction JSONB,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processed', 'confirmed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create family_media table
CREATE TABLE IF NOT EXISTS family_media (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_member_id UUID NOT NULL REFERENCES family_members(id) ON DELETE CASCADE,
  media_url TEXT NOT NULL,
  media_type TEXT NOT NULL CHECK (media_type IN ('photo', 'video')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_family_members_user_id ON family_members(user_id);
CREATE INDEX idx_family_relationships_user_id ON family_relationships(user_id);
CREATE INDEX idx_family_relationships_person_a ON family_relationships(person_a_id);
CREATE INDEX idx_family_relationships_person_b ON family_relationships(person_b_id);
CREATE INDEX idx_family_stories_user_id ON family_stories(user_id);
CREATE INDEX idx_family_stories_family_member_id ON family_stories(family_member_id);
CREATE INDEX idx_family_media_family_member_id ON family_media(family_member_id);

-- Enable Row Level Security
ALTER TABLE family_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_media ENABLE ROW LEVEL SECURITY;

-- RLS Policies for family_members
CREATE POLICY "Users can view their own family members" 
  ON family_members FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own family members" 
  ON family_members FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own family members" 
  ON family_members FOR UPDATE 
  USING (auth.uid() = user_id) 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own family members" 
  ON family_members FOR DELETE 
  USING (auth.uid() = user_id);

-- RLS Policies for family_relationships
CREATE POLICY "Users can view their own relationships" 
  ON family_relationships FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own relationships" 
  ON family_relationships FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own relationships" 
  ON family_relationships FOR UPDATE 
  USING (auth.uid() = user_id) 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own relationships" 
  ON family_relationships FOR DELETE 
  USING (auth.uid() = user_id);

-- RLS Policies for family_stories
CREATE POLICY "Users can view their own stories" 
  ON family_stories FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own stories" 
  ON family_stories FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own stories" 
  ON family_stories FOR UPDATE 
  USING (auth.uid() = user_id) 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own stories" 
  ON family_stories FOR DELETE 
  USING (auth.uid() = user_id);

-- RLS Policies for family_media
CREATE POLICY "Users can view media for their family members" 
  ON family_media FOR SELECT 
  USING (
    family_member_id IN (
      SELECT id FROM family_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert media for their family members" 
  ON family_media FOR INSERT 
  WITH CHECK (
    family_member_id IN (
      SELECT id FROM family_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete media for their family members" 
  ON family_media FOR DELETE 
  USING (
    family_member_id IN (
      SELECT id FROM family_members WHERE user_id = auth.uid()
    )
  );
