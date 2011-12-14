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
    #
    # @return [PacketIn] the packet in to authenticate.
    #
    attr_reader :packet_in
    #
    # @return [Array] an array of PacketIn class methods.
    #
    attr_reader :packet_in_methods


    #
    # Saves subclasses instances.
    #
    # @param [ArpFilter, DhcpBootpFilter, DnsTcpFilter, DnsUdpFilter] subclass
    #   all known subclasses of AuthenticationFilter class.
    #
    # @return [Array] an array of subclasses class objects.
    #
    def inherited subclass
      @subclasses << subclass
    end


    #
    # Authenticates a packet in message by calling a common allow method
    # on each subclass instance.
    #
    # @param [PacketIn] packet_in
    #   the context of the packet in message.
    #
    # @return [Array]
    #   an empty array if authentication is passed otherwise an non
    #   empty array of authentication filter subclasses instances.
    #
    def apply packet_in
      @packet_in_methods = packet_in.class.instance_methods( false )
      @packet_in = packet_in
      @subclasses.select { | subclass | subclass.new.allow? }
    end
  end


  #
  # For each authentication filter subclass sets each instance variable to the
  # value of the packet in instance variable.
  #
  # @param [Array] attributes one or more attributes corresponding to mapped packet's in
  #   instance variables.
  #
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
  #
  # Inspects the UDP source or destination port of a packet in. To pass 
  # authentication the UDP source or destination must be either 67 or 68
  # (DHCP port).
  #
  # @return [Boolean] true if passes authentication, otherwise false.
  #
  def allow?
    filter_attributes :udp_src_port, :udp_dst_port
    return @udp_src_port == 67 || @udp_src_port == 68 || @udp_dst_port == 67 || @udp_dst_port == 68
  end
end


class DnsUdpFilter < AuthenticationFilter
  #
  # Inspects the UDP source or destination port of a packet in. To pass
  # authentication the UDP source or destination port must be 
  # 53 (DNS UDP port).
  #
  # @return [Boolean] true if passes authentication otherwise false.
  #
  def allow?
    filter_attributes :udp_src_port, :udp_dst_port
    return @udp_src_port == 53 || @udp_dst_port == 53
  end
end


class DnsTcpFilter < AuthenticationFilter
  #
  # Inspects the TCP source or destination port of a packet in. To pass
  # authentication the TCP source or destination port must be
  # 53 (DNS TCP port).
  #
  # @return [Boolean] true if passes authentication otherwise false.
  #
  def allow?
    filter_attributes :tcp_src_port, :tcp_dst_port
    return @tcp_src_port == 53 || @tcp_dst_port == 53
  end
end


class ArpFilter < AuthenticationFilter
  #
  # Passes the authentication if the packet in is an arp packet.
  #
  # @return [Boolean] 
  #   true if user packet in is an arp packet and passes the authentication 
  #   otherwise false.
  #
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
