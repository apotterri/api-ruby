#
# Copyright (C) 2013 Conjur Inc
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
module Conjur
  # This class represents a {http://developer.conjur.net/reference/services/directory/host
  # Conjur Host} asset.  You should not create {Conjur::Host} instances directly, but use {Conjur::API}
  # methods such as {Conjur::API#create_host} and {Conjur::API#host}.
  class Host < Deputy

    # @api private
    # @deprecated
    #
    # This method was used before conjurize came along.  It's no longer in use.
    def enrollment_url
      log do |logger|
        logger << "Fetching enrollment_url for #{id}"
      end
      self['enrollment_url'].head{|response, request, result| response }.headers[:location]
    end
  end
end