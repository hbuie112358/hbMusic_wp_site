# The rules for site.json (template plan T7): every field the tools read, its type, whether it is
# required, for text that becomes part of other names the characters it may use, and for a
# choice its allowed values. The one definition of
# the fields: the check of site.json and the check of its explanation (tools/site-settings.md)
# both read it, so they cannot disagree. Loaded with `jq -L tools 'include "site-settings"; ...'`.
#
# A yes/no field left out means the usual case, so only the exceptions are written.

# A place bin/deploy copies to, the same fields for each.
def site_settings_place_rules($is_required): {
  type: "object", required: $is_required,
  fields: {
    # A short name from the user's SSH settings (~/.ssh/config), which hold the server's address,
    # account, port and key; the characters ssh allows in such a name.
    sshHost: { type: "string", required: true, pattern: "^[A-Za-z0-9][A-Za-z0-9._-]*$", patternMeaning: "a short name from the SSH settings: letters, digits, dots, dashes and underscores" },
    # The site's root, which the page check opens: https only, nothing after the host, and no
    # login before it ("user:password@"), so no password is ever written into this file.
    address: { type: "string", required: true, pattern: "^https://[^/?#@\\s]+$", patternMeaning: "https:// and the site's host, with no login, path or slash, such as https://example.com" },
    isBehindPassword: { type: "boolean", required: false }
  }
};

def site_settings_rules: {
  type: "object",
  fields: {
    # The slug becomes part of Docker's names (the caches, the dev site's database, the compose
    # project), which allow only some characters; lower case keeps them all alike.
    slug: { type: "string", required: true, pattern: "^[a-z0-9][a-z0-9-]*$", patternMeaning: "lower-case letters, digits and dashes, starting with a letter or digit" },
    devSiteTitle: { type: "string", required: true },
    # A folder name under themes/, never a path: the same characters as the slug.
    theme: { type: "string", required: true, pattern: "^[a-z0-9][a-z0-9-]*$", patternMeaning: "a folder name under themes/: lower-case letters, digits and dashes, starting with a letter or digit" },
    # Folder names under plugins/, never paths: they become mounts in compose.site.yaml.
    localPlugins: { type: "array", required: true, items: { type: "string", pattern: "^[a-z0-9][a-z0-9-]*$", patternMeaning: "a folder name under plugins/: lower-case letters, digits and dashes, starting with a letter or digit" } },
    testPages: {
      type: "array", required: true,
      items: {
        type: "object",
        fields: {
          title: { type: "string", required: true },
          address: { type: "string", required: true },
          pageTemplate: { type: "string", required: false },
          isFrontPage: { type: "boolean", required: false },
          isPrivacyPolicy: { type: "boolean", required: false },
          isInMenu: { type: "boolean", required: false }
        }
      }
    },
    namesSharedCodeMustNotUse: { type: "array", required: true, items: { type: "string" } },
    # Where bin/deploy copies the site to (template plan T11). Left out by a site not deployed yet.
    deploy: {
      type: "object", required: false,
      fields: {
        # Stated, never assumed: a host with a page cache the tools cannot clear yet is refused,
        # instead of a deploy leaving visitors the old pages.
        pageCache: { type: "string", required: true, allowedValues: ["none"] },
        live: site_settings_place_rules(true),
        staging: site_settings_place_rules(false)
      }
    }
  }
};

# "testPages" and "title" become "testPages[2].title"; at the top level a field is its own name.
def site_settings_join_path($where; $key):
  if $where == "" then $key else "\($where).\($key)" end;

# Each problem with the value at the input, as a line naming where it is and what was expected.
# Objects are checked for missing, unknown and then each known field; arrays item by item.
def site_settings_problems_at($rules; $where):
  def shown: if $where == "" then "site.json" else $where end;
  if type != $rules.type then
    "\(shown): expected \($rules.type), found \(type)"
  elif $rules.type == "object" then
    . as $object
    | ($rules.fields | to_entries[]
        | select(.key as $key | .value.required and ($object | has($key) | not))
        | "\(site_settings_join_path($where; .key)): missing (required)"),
      ($object | keys_unsorted[]
        | select(. as $key | $rules.fields | has($key) | not)
        | "\(site_settings_join_path($where; .)): not a known field (a typo?)"),
      ($rules.fields | to_entries[] | select(.key as $key | $object | has($key))
        | .key as $key | .value as $field_rules
        | $object[$key] | site_settings_problems_at($field_rules; site_settings_join_path($where; $key)))
  elif $rules.type == "array" then
    to_entries[] | .key as $index | .value
    | site_settings_problems_at($rules.items; "\($where)[\($index)]")
  elif ($rules.allowedValues // null) != null and (. as $value | $rules.allowedValues | any(.[]; . == $value) | not) then
    "\(shown): \(tojson) must be one of \($rules.allowedValues | map(tojson) | join(", "))"
  elif ($rules.pattern // null) != null and (test($rules.pattern) | not) then
    "\(shown): \(tojson) must be \($rules.patternMeaning)"
  else
    empty
  end;

# Rules across fields, which the field-by-field rules cannot see. Staging and live must be two
# places: with the same short name or address, a deploy to staging would land on live, skipping
# the look at staging, and the page check would test the wrong site. Checked only when both are
# objects; their own rules report anything else.
def site_settings_deploy_problems:
  (.deploy? // null) as $deploy
  | if ($deploy | type) == "object" and ($deploy.live | type) == "object" and ($deploy.staging | type) == "object" then
      ("sshHost", "address") as $field
      | select($deploy.staging[$field] != null and $deploy.staging[$field] == $deploy.live[$field])
      | "deploy.staging.\($field): the same as deploy.live.\($field); staging and live must be two places"
    else
      empty
    end;

def site_settings_problems: site_settings_problems_at(site_settings_rules; ""), site_settings_deploy_problems;

# Every field's name as the explanation page heads it: "testPages", "testPages[].title".
def site_settings_field_names_at($rules; $prefix):
  if $rules.type == "object" then
    $rules.fields | to_entries[]
    | site_settings_join_path($prefix; .key) as $name
    | $name, site_settings_field_names_at(.value; $name)
  elif $rules.type == "array" then
    site_settings_field_names_at($rules.items; "\($prefix)[]")
  else
    empty
  end;

def site_settings_field_names: site_settings_field_names_at(site_settings_rules; "");
