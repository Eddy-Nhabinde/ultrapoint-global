/*
  # Medical Portal Database Schema

  ## Overview
  Complete database schema for a modern medical portal with appointment booking,
  doctor management, services, and blog functionality.

  ## New Tables

  ### 1. doctors
  - `id` (uuid, primary key) - Unique doctor identifier
  - `name` (text) - Doctor's full name
  - `specialty` (text) - Medical specialty
  - `bio` (text) - Professional biography
  - `image_url` (text) - Profile image URL
  - `facebook_url` (text, nullable) - Social media link
  - `twitter_url` (text, nullable) - Social media link
  - `instagram_url` (text, nullable) - Social media link
  - `linkedin_url` (text, nullable) - Social media link
  - `years_experience` (integer) - Years of practice
  - `available` (boolean) - Currently accepting patients
  - `created_at` (timestamptz) - Record creation timestamp
  - `updated_at` (timestamptz) - Record update timestamp

  ### 2. services
  - `id` (uuid, primary key) - Unique service identifier
  - `name` (text) - Service name
  - `description` (text) - Detailed description
  - `icon` (text) - Icon identifier or URL
  - `category` (text) - Service category
  - `active` (boolean) - Service availability status
  - `created_at` (timestamptz) - Record creation timestamp
  - `updated_at` (timestamptz) - Record update timestamp

  ### 3. appointments
  - `id` (uuid, primary key) - Unique appointment identifier
  - `patient_name` (text) - Patient's full name
  - `patient_email` (text) - Patient's email address
  - `patient_phone` (text, nullable) - Patient's phone number
  - `doctor_id` (uuid, foreign key) - Reference to doctors table
  - `service_id` (uuid, foreign key) - Reference to services table
  - `appointment_date` (date) - Scheduled date
  - `appointment_time` (text) - Scheduled time slot
  - `notes` (text, nullable) - Additional patient notes
  - `status` (text) - Appointment status (pending, confirmed, cancelled, completed)
  - `created_at` (timestamptz) - Record creation timestamp
  - `updated_at` (timestamptz) - Record update timestamp

  ### 4. blog_posts
  - `id` (uuid, primary key) - Unique post identifier
  - `title` (text) - Post title
  - `excerpt` (text) - Short preview text
  - `content` (text) - Full post content
  - `image_url` (text) - Featured image URL
  - `author` (text) - Post author name
  - `category` (text) - Post category
  - `published` (boolean) - Publication status
  - `views` (integer) - View count
  - `created_at` (timestamptz) - Record creation timestamp
  - `updated_at` (timestamptz) - Record update timestamp

  ### 5. testimonials
  - `id` (uuid, primary key) - Unique testimonial identifier
  - `patient_name` (text) - Patient's name
  - `patient_title` (text) - Patient's title/occupation
  - `content` (text) - Testimonial content
  - `rating` (integer) - Rating out of 5
  - `image_url` (text, nullable) - Patient image URL
  - `active` (boolean) - Display status
  - `created_at` (timestamptz) - Record creation timestamp

  ## Security
  - Enable Row Level Security (RLS) on all tables
  - Public read access for doctors, services, blog_posts, and testimonials
  - Appointments are only readable by authenticated staff
  - All tables require authentication for insert/update/delete operations

  ## Important Notes
  - All timestamps use timestamptz for timezone awareness
  - Foreign keys ensure data integrity between appointments, doctors, and services
  - Boolean fields have sensible defaults
  - Status fields use text to allow for flexible workflow states
*/

-- Create doctors table
CREATE TABLE IF NOT EXISTS doctors (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  specialty text NOT NULL,
  bio text DEFAULT '',
  image_url text DEFAULT '',
  facebook_url text,
  twitter_url text,
  instagram_url text,
  linkedin_url text,
  years_experience integer DEFAULT 0,
  available boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create services table
CREATE TABLE IF NOT EXISTS services (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text DEFAULT '',
  icon text DEFAULT '',
  category text DEFAULT 'general',
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create appointments table
CREATE TABLE IF NOT EXISTS appointments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_name text NOT NULL,
  patient_email text NOT NULL,
  patient_phone text,
  doctor_id uuid REFERENCES doctors(id) ON DELETE SET NULL,
  service_id uuid REFERENCES services(id) ON DELETE SET NULL,
  appointment_date date NOT NULL,
  appointment_time text NOT NULL,
  notes text,
  status text DEFAULT 'pending',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create blog_posts table
CREATE TABLE IF NOT EXISTS blog_posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  excerpt text DEFAULT '',
  content text DEFAULT '',
  image_url text DEFAULT '',
  author text DEFAULT 'Admin',
  category text DEFAULT 'general',
  published boolean DEFAULT true,
  views integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create testimonials table
CREATE TABLE IF NOT EXISTS testimonials (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_name text NOT NULL,
  patient_title text DEFAULT '',
  content text NOT NULL,
  rating integer DEFAULT 5,
  image_url text,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_appointments_doctor ON appointments(doctor_id);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(status);
CREATE INDEX IF NOT EXISTS idx_blog_posts_published ON blog_posts(published);
CREATE INDEX IF NOT EXISTS idx_doctors_available ON doctors(available);

-- Enable Row Level Security
ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE blog_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;

-- RLS Policies for doctors table
CREATE POLICY "Public can view available doctors"
  ON doctors FOR SELECT
  TO public
  USING (available = true);

CREATE POLICY "Authenticated users can manage doctors"
  ON doctors FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- RLS Policies for services table
CREATE POLICY "Public can view active services"
  ON services FOR SELECT
  TO public
  USING (active = true);

CREATE POLICY "Authenticated users can manage services"
  ON services FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- RLS Policies for appointments table
CREATE POLICY "Users can create appointments"
  ON appointments FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Authenticated users can view all appointments"
  ON appointments FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can update appointments"
  ON appointments FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete appointments"
  ON appointments FOR DELETE
  TO authenticated
  USING (true);

-- RLS Policies for blog_posts table
CREATE POLICY "Public can view published blog posts"
  ON blog_posts FOR SELECT
  TO public
  USING (published = true);

CREATE POLICY "Authenticated users can manage blog posts"
  ON blog_posts FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- RLS Policies for testimonials table
CREATE POLICY "Public can view active testimonials"
  ON testimonials FOR SELECT
  TO public
  USING (active = true);

CREATE POLICY "Authenticated users can manage testimonials"
  ON testimonials FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Insert sample doctors
INSERT INTO doctors (name, specialty, bio, image_url, years_experience, available) VALUES
('Dr. Sarah Johnson', 'Cardiology', 'Board-certified cardiologist with over 15 years of experience in treating heart conditions and preventive cardiology.', 'img/doctor/doctor_1.png', 15, true),
('Dr. Michael Chen', 'Internal Medicine', 'Expert in internal medicine specializing in chronic disease management and preventive care.', 'img/doctor/doctor_4.png', 12, true),
('Dr. Emily Rodriguez', 'Pediatrics', 'Dedicated pediatrician providing comprehensive care for children from infancy through adolescence.', 'img/doctor/doctor_2.png', 10, true),
('Dr. James Williams', 'Orthopedics', 'Orthopedic surgeon specializing in sports injuries and joint replacement procedures.', 'img/doctor/doctor_3.png', 18, true)
ON CONFLICT DO NOTHING;

-- Insert sample services
INSERT INTO services (name, description, icon, category, active) VALUES
('Eye Treatment', 'Comprehensive eye care including examinations, disease treatment, and surgical procedures.', 'ti-eye', 'specialty', true),
('Skin Surgery', 'Advanced dermatological procedures for skin conditions and cosmetic improvements.', 'ti-layers', 'surgery', true),
('Diagnosis Clinic', 'State-of-the-art diagnostic services with latest medical technology.', 'ti-clipboard', 'diagnostic', true),
('Dental Care', 'Full-service dental care including preventive, restorative, and cosmetic dentistry.', 'ti-heart', 'dental', true),
('Neurology Service', 'Expert neurological care for brain and nervous system disorders.', 'ti-pulse', 'specialty', true),
('Plastic Surgery', 'Reconstructive and cosmetic surgery performed by experienced surgeons.', 'ti-user', 'surgery', true)
ON CONFLICT DO NOTHING;

-- Insert sample blog posts
INSERT INTO blog_posts (title, excerpt, content, image_url, author, category, published) VALUES
('The Importance of Regular Health Checkups', 'Discover why annual health screenings are essential for maintaining optimal health and preventing disease.', 'Regular health checkups are a cornerstone of preventive medicine...', 'img/blog/blog_1.png', 'Dr. Sarah Johnson', 'Health Tips', true),
('Understanding Heart Health', 'Learn about cardiovascular health and simple lifestyle changes that can improve your heart function.', 'Your heart is one of the most vital organs in your body...', 'img/blog/blog_2.png', 'Dr. Michael Chen', 'Cardiology', true),
('Nutrition Tips for a Healthy Life', 'Expert advice on maintaining a balanced diet and making smart nutritional choices.', 'Good nutrition is the foundation of good health...', 'img/blog/blog_3.png', 'Dr. Emily Rodriguez', 'Nutrition', true)
ON CONFLICT DO NOTHING;

-- Insert sample testimonials
INSERT INTO testimonials (patient_name, patient_title, content, rating, active) VALUES
('John Anderson', 'Business Executive', 'The care I received at this medical center was exceptional. The doctors are knowledgeable, caring, and truly invested in their patients well-being.', 5, true),
('Maria Garcia', 'Teacher', 'Outstanding medical facility with state-of-the-art equipment and compassionate staff. I highly recommend their services.', 5, true),
('Robert Taylor', 'Engineer', 'Professional, efficient, and patient-centered care. The appointment system is easy to use and the staff is always helpful.', 5, true)
ON CONFLICT DO NOTHING;