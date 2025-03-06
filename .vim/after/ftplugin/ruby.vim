if expand('%:t') ==? 'Rakefile'
  " There isn't many good reasons to open a Rakefile unless I'm working on a
  " ruby based project. So just set this as the compiler globally.
  compiler! rake
endif
