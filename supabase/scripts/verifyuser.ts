// Supabase credentials
const SUPABASE_URL = "https://lhrtltchvbshelpowpbz.supabase.co";
const SUPABASE_SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxocnRsdGNodmJzaGVscG93cGJ6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTY3NzA3OSwiZXhwIjoyMDg3MjUzMDc5fQ.2dYABQKCPz9fv_Ani-4Ubutv-Z9UGANaoFUofnmyZrc";

async function verifyAllUsers() {
  console.log("Fetching all users via REST API...");

  const listResponse = await fetch(`${SUPABASE_URL}/auth/v1/admin/users`, {
    headers: {
      "apikey": SUPABASE_SERVICE_ROLE_KEY,
      "Authorization": `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
    }
  });

  if (!listResponse.ok) {
    const errorText = await listResponse.text();
    console.error("Error listing users:", errorText);
    return;
  }

  const data = await listResponse.json();
  const users = data.users || [];

  console.log(`Found ${users.length} users. Starting verification...`);

  for (const user of users) {
    if (!user.email_confirmed_at) {
      console.log(`Verifying user: ${user.email} (${user.id})`);

      const updateResponse = await fetch(`${SUPABASE_URL}/auth/v1/admin/users/${user.id}`, {
        method: "PUT",
        headers: {
          "apikey": SUPABASE_SERVICE_ROLE_KEY,
          "Authorization": `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          email_confirm: true
        })
      });

      if (!updateResponse.ok) {
        const errorText = await updateResponse.text();
        console.error(`  - Failed to verify ${user.email}:`, errorText);
      } else {
        console.log(`  + Successfully verified ${user.email}`);
      }
    } else {
      console.log(`  . ${user.email} is already verified.`);
    }
  }

  console.log("Verification process complete.");
}

verifyAllUsers().catch(console.error);
