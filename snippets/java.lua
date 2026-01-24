-- Replace the friendly-snippets section in your myplugs.lua with this:
-- Or better yet, REMOVE it entirely since it's already loaded in 4-dev.lua

-- If you want to keep custom Java snippets, do this instead:
-- Create a new file: ~/.config/nvim/snippets/java.lua

-- Then add this content to that file:
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- Main method (trigger: psvm)
  s("psvm", {
    t("public static void main(String[] args) {"),
    t({"", "\t"}),
    i(0),
    t({"", "}"}),
  }),

  -- System.out.println (trigger: sout)
  s("sout", {
    t("System.out.println("),
    i(1),
    t(");"),
  }),

  -- For-each loop (trigger: foreach)
  s("foreach", {
    t("for ("),
    i(1, "Type"),
    t(" "),
    i(2, "item"),
    t(" : "),
    i(3, "collection"),
    t(") {"),
    t({"", "\t"}),
    i(0),
    t({"", "}"}),
  }),

  -- Try-catch (trigger: tryc)
  s("tryc", {
    t("try {"),
    t({"", "\t"}),
    i(1),
    t({"", "} catch ("}),
    i(2, "Exception"),
    t(" "),
    i(3, "e"),
    t(") {"),
    t({"", "\t"}),
    i(0),
    t({"", "}"}),
  }),
}
