# The rules for site.json (template plan T7): every field the tools read, its type, whether it is
# required and, for text that becomes part of other names, the characters it may use. The one definition of
# the fields: the check of site.json and the check of its explanation (tools/site-settings.md)
# both read it, so they cannot disagree. Loaded with `jq -L tools 'include "site-settings"; ...'`.
#
# A yes/no field left out means the usual case, so only the exceptions are written.

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
    namesPluginsMustNotUse: { type: "array", required: true, items: { type: "string" } }
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
  elif ($rules.pattern // null) != null and (test($rules.pattern) | not) then
    "\(shown): \(tojson) must be \($rules.patternMeaning)"
  else
    empty
  end;

def site_settings_problems: site_settings_problems_at(site_settings_rules; "");

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
