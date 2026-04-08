-- HomeLinkGH RLS Fix — run in Supabase SQL Editor for project leuizklnwukrseocweyu

-- ─── admin_users ────────────────────────────────────────────────────────────
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Only admins can view admin list"
  ON admin_users FOR SELECT
  USING (auth.uid() IN (SELECT id FROM admin_users));

CREATE POLICY "Only admins can insert"
  ON admin_users FOR INSERT
  WITH CHECK (auth.uid() IN (SELECT id FROM admin_users));

-- ─── error_logs ─────────────────────────────────────────────────────────────
ALTER TABLE error_logs ENABLE ROW LEVEL SECURITY;

-- Any authenticated user can write error logs (needed for app telemetry)
CREATE POLICY "Authenticated users can insert error logs"
  ON error_logs FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- Only admins can read error logs
CREATE POLICY "Only admins can read error logs"
  ON error_logs FOR SELECT
  USING (auth.uid() IN (SELECT id FROM admin_users));
