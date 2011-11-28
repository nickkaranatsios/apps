#
# Author: Nick Karanatsios <nickkaranatsios@gmail.com>
#
# Copyright (C) 2008-2011 NEC Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

require "trema/model"


class RoutingSwitchOptions < Model::Options
  def parse!( args )
    super
    args.options do |opts|
      opts.on( "-i",
        "--idle-timeout TIMEOUT",
        "Idle timeout value for flow entry" ) do | t |
        @options[ :idle_timeout ] = t.to_i
      end
      opts.on( "-d",
        "-packet-in-discard-duration DURATION",
        "hard timeout value for packet_in discard duration" ) do | t |
        @options[ :packet_in_discard_duration ] = t.to_i
      end
    end.parse!
    self
  end


  def default_options
    {
      :idle_timeout => 60,
      :packet_in_discard_duration => 1
    }
  end


  def idle_timeout
    @options[ :idle_timeout ]
  end


  def discard_packet_in_duration
    @options[ :packet_in_discard_duration ]
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
