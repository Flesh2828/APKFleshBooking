import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://wmtdckxqsgjmuwvikleb.supabase.co';
const supabaseAnonKey =
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ||
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndtdGRja3hxc2dqbXV3dmlrbGViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA2NTk3OTUsImV4cCI6MjEwNjIzNTc5NX0.aZf8-x9znllJy3ONrbECsc1T30NeigcrsT64k8hem5U';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
