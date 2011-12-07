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


class AuthenticationFilter
  @subclasses = []


  class << self
    attr_reader :packet_in
    attr_reader :packet_in_methods


    def inherited subclass
      @subclasses << subclass
    end


    def apply packet_in
      @packet_in_methods = packet_in.class.instance_methods( false )
      @packet_in = packet_in
      @subclasses.select { | subclass | subclass.new.allow? }
    end
  end


  def filter_attributes *attributes
    attributes.each_index do | i |
      attribute = attributes[ i ].to_s
      match = AuthenticationFilter.packet_in_methods.select { | v | v == attribute or v == attribute + "?" }
      if match.length == 1
        instance_variable_set( "@#{ attributes[ i ] }", AuthenticationFilter.packet_in.send( match.to_s ) )
        instance_variable_get "@#{ attributes[ i ] }"
      end
    end
  end
end



class DhcpBootpFilter < AuthenticationFilter
  def allow?
    filter_attributes :udp_src_port, :udp_dst_port
    return @udp_src_port == 67 || @udp_src_port == 68 || @udp_dst_port == 67 || @udp_dst_port == 68
  end
end


class DnsUdpFilter < AuthenticationFilter
  def allow?
    filter_attributes :udp_src_port, :udp_dst_port
    return @udp_src_port == 53 || @udp_dst_port == 53
  end
end


class DnsTcpFilter < AuthenticationFilter
  def allow?
    filter_attributes :tcp_src_port, :tcp_dst_port
    return @tcp_src_port == 53 || @tcp_dst_port == 53
  end
end


class ArpFilter < AuthenticationFilter
  def allow?
    filter_attributes :arp
    return @arp
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
