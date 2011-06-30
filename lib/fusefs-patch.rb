# FuseFS is a little broken. We can fix it here until it's
# fixed in the distribution
def FuseFS.run
  fd = FuseFS.fuse_fd
  begin
    io = IO.for_fd(fd)
  rescue Errno::EBADF
    raise "fuse is not mounted"
  end
  while @running
    reads, foo, errs = IO.select([io],nil,[io])
    break unless FuseFS.process
  end
end
