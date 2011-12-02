$:.unshift( File.dirname( __FILE__ ) + '/../../trema/ruby')
$:.unshift( File.dirname( __FILE__ ) + '/../../trema/spec')
$:.unshift( File.dirname( __FILE__ ) + '/../topology')
$:.unshift( File.dirname( __FILE__ ) + '/../path_resolver_client')


#require "spec_helper"


require "rubygems"

require "rspec"
require "trema"
require "trema/dsl/context"
require "trema/ofctl"
require "trema/shell-commands"
require "trema/util"
Dir.glob( File.join( File.dirname( __FILE__ ), '*_supportspec.rb' ) ).each do | file |
  require File.basename( file, File.extname( file ) )
end

ENV[ 'TREMA_TMP' ] = File.expand_path( 'tmp' )

include Trema::Util


class Network
  def initialize &block
    @context = Trema::DSL::Parser.new.eval( &block )
    $context = @context
  end


  def run controller_class, &test
    begin
      trema_run controller_class
      test.call
    ensure
      trema_kill
    end
  end


  ################################################################################
  private
  ################################################################################


  def trema_run controller_class
    controller = controller_class.new
    if not controller.is_a?( Trema::Controller )
      raise "#{ controller_class } is not a subclass of Trema::Controller"
    end
    @context.dump_to Trema::DSL::Parser::CURRENT_CONTEXT
    maybe_run_switch_manager
    maybe_run_packetin_filter
    maybe_create_links
    maybe_run_hosts
    maybe_run_switches
    
=begin
    @context.links.each do | name, each |
      each.add!
    end
    @context.hosts.each do | name, each |
      each.run!
    end
    @context.links.each do | name, each |
      each.up!
    end
    @context.hosts.each do | name, each |
      each.add_arp_entry @context.hosts.values - [ each ]
    end
    @context.switches.each do | name, each |
      each.run!
      drop_packets_from_unknown_hosts each
    end
=end
    maybe_run_apps

    @th_controller = Thread.start do
      controller.run!
    end
    sleep 2  # FIXME: wait until controller.up?
  end
  

  def maybe_run_switch_manager
    switch_manager =
    if @context.switch_manager
      last_app = @context.apps.values.last.name
      if not @context.switch_manager.rule.has_key?( :port_status )
        @context.switch_manager.rule[ :port_status ] = last_app
      end
      if not @context.switch_manager.rule.has_key?( :packet_in )
        @context.switch_manager.rule[ :packet_in ] = last_app
      end
      if not @context.switch_manager.rule.has_key?( :state_notify )
        @context.switch_manager.rule[ :state_notify ] = last_app
      end
      if not @context.switch_manager.rule.has_key?( :vendor )
        @context.switch_manager.rule[ :vendor ] = last_app
      end
      @context.switch_manager
    else
      if @context.apps.values.size == 0
        rule = { :port_status => "default", :packet_in => "default", :state_notify => "default", :vendor => "default" }
      elsif @context.apps.values.size == 1
        app_name = @context.apps.values[ 0 ].name
        rule = { :port_status => app_name, :packet_in => app_name, :state_notify => app_name, :vendor => app_name }
      else
        # two or more apps without switch_manager.
        raise "No event routing configured. Use `event' directive to specify event routing."
      end
      SwitchManager.new( rule, @context.port )
    end
    switch_manager.run!
  end


  def maybe_create_links
    maybe_delete_links # Fool proof
    @context.links.each do | name, link |
      link.enable!
    end
  end


  def maybe_delete_links
    @context.links.each do | name, link |
      link.delete!
    end
  end


  def maybe_run_hosts
    @context.hosts.each do | name, host |
      host.run!
    end
  end


  def maybe_run_packetin_filter
    @context.packetin_filter.run! if @context.packetin_filter
  end


  def maybe_run_switches
    @context.switches.each do | name, switch |
      switch.run!
    end

    @context.hosts.each do | name, host |
      host.add_arp_entry @context.hosts.values - [ host ]
    end
  end


  def maybe_run_apps
    return if @context.apps.values.empty?

    @context.apps.values[ 0..-2 ].each do | each |
      each.daemonize!
    end
    trap( "SIGINT" ) do
      print( "\nterminated\n" )
      exit(0)
    end
    pid = ::Process.fork do
      @context.apps.values.last.run!
    end
    ::Process.waitpid pid
  end


  def trema_kill
    cleanup_current_session
    @th_controller.join if @th_controller
    sleep 2  # FIXME: wait until switch_manager.down?
  end


  def drop_packets_from_unknown_hosts switch
    ofctl = Trema::Ofctl.new
    ofctl.add_flow switch, :priority => 0, :actions => "drop"
    @context.hosts.each do | name, each |
      ofctl.add_flow switch, :dl_type => "0x0800", :nw_src => each.ip, :priority => 1, :actions => "controller"
    end
  end
end


def network &block
  Network.new &block
end

