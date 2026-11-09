# ROBO CELL — Supabase Authentication Architecture

## Overview
This document specifies the target authentication and authorization architecture for the ROBO CELL Flutter application on Supabase.

### Primary Objectives:
1. **Supabase Auth Integration:** All users authenticate via Supabase Auth (`supabase.auth.signInWithPassword`).
2. **Row Level Security (RLS):** All table operations are protected using native Supabase RLS policies tied to `auth.uid()`.
3. **Secure Profile Resolution:** User profiles are retrieved via `auth_user_id` linkage and the `get_current_user_profile()` RPC.
4. **Public Directory Safety:** Views like `login_members_directory` and `committee_members_view` expose only public fields (name, USN, role, committee_id) and NEVER expose passwords or auth IDs.
