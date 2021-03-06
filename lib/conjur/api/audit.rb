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

require 'conjur/event_source'
module Conjur


  class API
    #@!group Audit Service

    # Return up to 100 audit events visible to the current authorized role.
    #
    # An audit event is visible to a role if that role or one of it's ancestors is in the
    #   event's `:roles` field, or the role has a privilege any of the event's `:resources` field.
    #
    # @param options [Hash]
    # @option options [Time, nil] :till only show events before this time
    # @option options [Time, nil] :since only show events after this time
    # @option options [Boolean] :follow block the current thread and call `block` with `Array` of
    #   audit events as the occur.
    #
    # @see #audit_role
    #
    # @return [Array<Hash>] the audit events
    def audit options={}, &block
      audit_event_feed "", options, &block
    end

    # Return up to 100 audit events visible to the current role and related to the given role.
    #
    # See {#audit} for the conditions under which an event is visible to a role.
    #
    # An event is said to be "related to" a role iff the role is a member of the event's
    # `:roles` field.
    #
    # @param role [Conjur::Role, String, #roleid] the role to audit (if a string is given, it must
    #   be of the form `'account:kind:id'`).
    # @param options [Hash]
    # @option options [Time, nil] :till only show events before this time
    # @option options [Time, nil] :since only show events after this time
    # @option options [Boolean] :follow block the current thread and call `block` with `Array` of
    #   audit events as the occur.
    #
    # @return [Array<Hash>] the audit events
    def audit_role role, options={}, &block
      audit_event_feed "roles/#{CGI.escape cast(role, :roleid)}", options, &block
    end

    # Return up to 100 audit events visible to the current role and related to the given resource.
    #
    # See {#audit} for the conditions under which an event is visible to a role.
    #
    # An event is said to be "related to" a role iff the role is a member of the event's
    #   `:roles` field.
    # @param resource [Conjur::Resource, String, #resourceid] the resource to audit (when a string is given, it must be
    #   of the form `'account:kind:id'`).
    # @param options [Hash]
    # @option options [Time, nil] :till only show events before this time
    # @option options [Time, nil] :since only show events after this time
    # @option options [Boolean] :follow block the current thread and call `block` with `Array` of
    #   audit events as the occur.
    #
    # @return [Array<Hash>] the audit events
    def audit_resource resource, options={}, &block
      audit_event_feed "resources/#{CGI.escape cast(resource, :resourceid)}", options, &block
    end

    #@!endgroup

    private
    def audit_event_feed path, options={}, &block
      query = options.slice(:since, :till)
      path << "?#{query.to_param}" unless query.empty? 
      if options[:follow]
        follow_events path, &block
      else
        parse_response(RestClient::Resource.new(Conjur::Audit::API.host, credentials)[path].get).tap do |events|
          block.call(events) if block
        end
      end
    end
    
    def follow_events path, &block
      opts = credentials.dup.tap{|h| h[:headers][:accept] = "text/event-stream"}
      block_response = lambda do |response|
        response.error! unless response.code == "200"
        es = EventSource.new
        es.message{ |e| block[e.data] }
        response.read_body do |chunk|
          es.feed chunk
        end
      end
      url = "#{Conjur::Audit::API.host}/#{path}"
      RestClient::Request.execute(
        url: url,
        headers: opts[:headers],
        method: :get,
        block_response: block_response
      )
    end
    
    def parse_response response
      JSON.parse response
    end
  end
end