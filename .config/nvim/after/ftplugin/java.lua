vim.api.nvim_buf_create_user_command(0, 'JdtTestClass', function()
  require('jdtls').test_class()
end, { desc = 'Test current class using Java JDT with DAP debugging capabilities enabled.' })

vim.api.nvim_buf_create_user_command(0, 'JdtTestNearestMethod', function()
  require('jdtls').test_nearest_method()
end, { desc = 'Test nearest method using Java JDT with DAP debugging capabilities enabled.' })
