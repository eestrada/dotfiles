if vim.g.vscode then
  return
end

-- Fuzzy keymaps

-- Keymap search is broken in fzf for some reason. Use telescope instead.
-- vim.keymap.set('n', '<leader>fk', ':Maps<CR>', { desc = '[F]uzzy search [K]eymaps' })
-- vim.keymap.set('n', '<leader>fp', ':Files<CR>', { desc = '[F]uzzy search project [P]aths' })
-- vim.keymap.set('n', '<leader>fv', ':GitFiles<CR>', { desc = '[F]uzzy search [V]ersion controlled file paths' })
-- vim.keymap.set('n', '<leader>fc', ':Commands<CR>', { desc = '[F]uzzy search [C]ommands' })
-- vim.keymap.set('n', '<leader>fs', ':Snippets<CR>', { desc = '[F]uzzy search [S]nippets' })
-- vim.keymap.set('n', '<leader>fb', ':Buffers<CR>', { desc = '[F]uzzy search [B]uffers' })
-- vim.keymap.set('n', '<leader>fh', ':Helptags<CR>', { desc = '[F]uzzy search [H]elp tags' })
-- vim.keymap.set('n', '<leader>fg', ':Rg<CR>', { desc = '[F]uzzy [G]rep files' })

-- All defined commands from the zfz plugin module as of the writing of this comment.
-- \'command!      -bang -nargs=? -complete=dir Files              call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)',
-- \'command!      -bang -nargs=? GitFiles                         call fzf#vim#gitfiles(<q-args>, fzf#vim#with_preview(<q-args> == "?" ? { "placeholder": "" } : {}), <bang>0)',
-- \'command!      -bang -nargs=? GFiles                           call fzf#vim#gitfiles(<q-args>, fzf#vim#with_preview(<q-args> == "?" ? { "placeholder": "" } : {}), <bang>0)',
-- \'command! -bar -bang -nargs=? -complete=buffer Buffers         call fzf#vim#buffers(<q-args>, fzf#vim#with_preview({ "placeholder": "{1}" }), <bang>0)',
-- \'command!      -bang -nargs=* Lines                            call fzf#vim#lines(<q-args>, <bang>0)',
-- \'command!      -bang -nargs=* BLines                           call fzf#vim#buffer_lines(<q-args>, <bang>0)',
-- \'command! -bar -bang Colors                                    call fzf#vim#colors(<bang>0)',
-- \'command!      -bang -nargs=+ -complete=dir Locate             call fzf#vim#locate(<q-args>, fzf#vim#with_preview(), <bang>0)',
-- \'command!      -bang -nargs=* Ag                               call fzf#vim#ag(<q-args>, fzf#vim#with_preview(), <bang>0)',
-- \'command!      -bang -nargs=* Rg                               call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case -- ".fzf#shellescape(<q-args>), fzf#vim#with_preview(), <bang>0)',
-- \'command!      -bang -nargs=* RG                               call fzf#vim#grep2("rg --column --line-number --no-heading --color=always --smart-case -- ", <q-args>, fzf#vim#with_preview(), <bang>0)',
-- \'command!      -bang -nargs=* Tags                             call fzf#vim#tags(<q-args>, fzf#vim#with_preview({ "placeholder": "--tag {2}:{-1}:{3..}" }), <bang>0)',
-- \'command!      -bang -nargs=* BTags                            call fzf#vim#buffer_tags(<q-args>, fzf#vim#with_preview({ "placeholder": "{2}:{3..}" }), <bang>0)',
-- \'command! -bar -bang Snippets                                  call fzf#vim#snippets(<bang>0)',
-- \'command! -bar -bang Commands                                  call fzf#vim#commands(<bang>0)',
-- \'command! -bar -bang Jumps                                     call fzf#vim#jumps(<bang>0)',
-- \'command! -bar -bang Marks                                     call fzf#vim#marks(<bang>0)',
-- \'command! -bar -bang Changes                                   call fzf#vim#changes(<bang>0)',
-- \'command! -bar -bang Helptags                                  call fzf#vim#helptags(fzf#vim#with_preview({ "placeholder": "--tag {2}:{3}:{4}" }), <bang>0)',
-- \'command! -bar -bang Windows                                   call fzf#vim#windows(fzf#vim#with_preview({ "placeholder": "{2}" }), <bang>0)',
-- \'command! -bar -bang -nargs=* -range=% -complete=file Commits  let b:fzf_winview = winsaveview() | <line1>,<line2>call fzf#vim#commits(<q-args>, fzf#vim#with_preview({ "placeholder": "" }), <bang>0)',
-- \'command! -bar -bang -nargs=* -range=% BCommits                let b:fzf_winview = winsaveview() | <line1>,<line2>call fzf#vim#buffer_commits(<q-args>, fzf#vim#with_preview({ "placeholder": "" }), <bang>0)',
-- \'command! -bar -bang Maps                                      call fzf#vim#maps("n", <bang>0)',
-- \'command! -bar -bang Filetypes                                 call fzf#vim#filetypes(<bang>0)',
-- \'command!      -bang -nargs=* History                          call s:history(<q-args>, fzf#vim#with_preview(), <bang>0)'])
