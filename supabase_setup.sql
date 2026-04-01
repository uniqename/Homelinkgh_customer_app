-- ============================================================================
-- HomeLinkGH Supabase Database Schema
-- INSTRUCTIONS: Go to your Supabase project > SQL Editor > New Query
-- Paste this entire file and click Run
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- USER PROFILES
-- ============================================================================
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  user_type TEXT NOT NULL DEFAULT 'customer',
  phone TEXT,
  location TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  fcm_token TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- ============================================================================
-- PROVIDERS
-- ============================================================================
CREATE TABLE IF NOT EXISTS providers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  services TEXT[] DEFAULT '{}',
  location TEXT,
  city TEXT DEFAULT 'Accra',
  status TEXT DEFAULT 'pending',
  is_verified BOOLEAN DEFAULT FALSE,
  fcm_token TEXT,
  rating NUMERIC(3,2) DEFAULT 0.0,
  total_jobs INTEGER DEFAULT 0,
  bio TEXT,
  ghana_card_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE providers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Verified providers visible to all authenticated" ON providers
  FOR SELECT USING (status = 'verified' OR user_id = auth.uid());
CREATE POLICY "Providers can update own" ON providers
  FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY "Providers can insert own" ON providers
  FOR INSERT WITH CHECK (user_id = auth.uid());

-- ============================================================================
-- SERVICE REQUESTS
-- ============================================================================
CREATE TABLE IF NOT EXISTS service_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  customer_name TEXT,
  customer_phone TEXT,
  service_type TEXT NOT NULL,
  description TEXT,
  location TEXT NOT NULL,
  budget NUMERIC(10,2),
  urgency TEXT DEFAULT 'Scheduled (within 3 days)',
  scheduled_date TIMESTAMPTZ,
  status TEXT DEFAULT 'open',
  answers JSONB DEFAULT '{}',
  media_urls TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE service_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Customers can create requests" ON service_requests
  FOR INSERT WITH CHECK (customer_id = auth.uid());
CREATE POLICY "Customers can view own requests" ON service_requests
  FOR SELECT USING (customer_id = auth.uid());
CREATE POLICY "Providers can view all open requests" ON service_requests
  FOR SELECT USING (status = 'open' AND auth.uid() IS NOT NULL);
CREATE POLICY "Customers can update own requests" ON service_requests
  FOR UPDATE USING (customer_id = auth.uid());

-- ============================================================================
-- QUOTES
-- ============================================================================
CREATE TABLE IF NOT EXISTS quotes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  service_request_id UUID REFERENCES service_requests(id) ON DELETE CASCADE,
  provider_id UUID REFERENCES providers(id) ON DELETE CASCADE,
  provider_name TEXT NOT NULL,
  amount NUMERIC(10,2) NOT NULL,
  description TEXT,
  breakdown JSONB,
  estimated_duration TEXT,
  provider_message TEXT,
  customer_message TEXT,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '7 days')
);

ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Providers can create quotes" ON quotes
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM providers WHERE id = provider_id AND user_id = auth.uid())
  );
CREATE POLICY "Providers can view own quotes" ON quotes
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM providers WHERE id = provider_id AND user_id = auth.uid())
  );
CREATE POLICY "Customers can view quotes for their requests" ON quotes
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM service_requests
      WHERE id = service_request_id AND customer_id = auth.uid()
    )
  );
CREATE POLICY "Customers can respond to quotes" ON quotes
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM service_requests
      WHERE id = service_request_id AND customer_id = auth.uid()
    )
  );

-- ============================================================================
-- NOTIFICATIONS
-- ============================================================================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT DEFAULT 'general',
  data JSONB,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notifications" ON notifications
  FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can mark own as read" ON notifications
  FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY "Authenticated users can send notifications" ON notifications
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- ============================================================================
-- MESSAGES (for quote/booking chat)
-- ============================================================================
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id TEXT NOT NULL,
  sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  type TEXT DEFAULT 'text',
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read messages" ON messages
  FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can send messages" ON messages
  FOR INSERT WITH CHECK (sender_id = auth.uid());

-- ============================================================================
-- BOOKINGS
-- ============================================================================
CREATE TABLE IF NOT EXISTS bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  service_request_id UUID REFERENCES service_requests(id),
  quote_id UUID REFERENCES quotes(id),
  customer_id UUID REFERENCES auth.users(id),
  provider_id UUID REFERENCES providers(id),
  service_type TEXT NOT NULL,
  scheduled_date TIMESTAMPTZ,
  location TEXT,
  amount NUMERIC(10,2),
  status TEXT DEFAULT 'pending',
  payment_status TEXT DEFAULT 'unpaid',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Customers can view own bookings" ON bookings
  FOR SELECT USING (customer_id = auth.uid());
CREATE POLICY "Providers can view own bookings" ON bookings
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM providers WHERE id = provider_id AND user_id = auth.uid())
  );
CREATE POLICY "Authenticated users can create bookings" ON bookings
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Booking participants can update" ON bookings
  FOR UPDATE USING (
    customer_id = auth.uid() OR
    EXISTS (SELECT 1 FROM providers WHERE id = provider_id AND user_id = auth.uid())
  );

-- ============================================================================
-- ADMIN USERS
-- ============================================================================
CREATE TABLE IF NOT EXISTS admin_users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT,
  full_name TEXT NOT NULL,
  role TEXT DEFAULT 'admin',
  permissions TEXT[] DEFAULT '{}',
  admin_secret_validated BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- ERROR LOGS
-- ============================================================================
CREATE TABLE IF NOT EXISTS error_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  error TEXT NOT NULL,
  context TEXT,
  metadata JSONB,
  user_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- ENABLE REALTIME for live updates
-- ============================================================================
ALTER PUBLICATION supabase_realtime ADD TABLE service_requests;
ALTER PUBLICATION supabase_realtime ADD TABLE quotes;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE messages;

-- ============================================================================
-- HELPER: total revenue for admin dashboard
-- ============================================================================
CREATE OR REPLACE FUNCTION get_total_revenue()
RETURNS NUMERIC AS $$
  SELECT COALESCE(SUM(amount), 0) FROM bookings WHERE payment_status = 'paid';
$$ LANGUAGE SQL SECURITY DEFINER;

-- ============================================================================
-- INITIAL ADMIN ACCOUNT
-- Change the email before running!
-- ============================================================================
INSERT INTO admin_users (email, full_name, role, permissions, admin_secret_validated, is_active)
VALUES (
  'admin@homelinkgh.com',
  'HomeLinkGH Admin',
  'super_admin',
  ARRAY['all'],
  TRUE,
  TRUE
) ON CONFLICT (email) DO NOTHING;
