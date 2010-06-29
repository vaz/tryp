# ridiculously oversimplified logging mechanism (tm)
# so I can refactor into sensible logging someday if I want
module Kernel
  def log msg; puts msg if $logging; end
end

