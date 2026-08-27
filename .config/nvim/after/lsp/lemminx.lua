local user_home = vim.fn.expand('~')
local lemminx_cfg = {
  filetypes = { 'xml', 'xsd', 'xsl', 'xslt', 'svg', 'ant' },
}

-- Only add a global XML catalog if it can be found.
local xml_catalog = user_home .. '/dev/catalog.xml'
if vim.fn.filereadable(xml_catalog) then
  lemminx_cfg.xml = { catalogs = { xml_catalog } }
end

return lemminx_cfg
