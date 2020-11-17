if ps#CanUseConsistency()
  setlocal tabstop=2 shiftwidth=2 softtabstop=2
endif
if ps#CanUseDadbod() | call ps#database#InitializeSQL() | endif
