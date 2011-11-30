/*
 * Author: Nick Karanatsios <nickkaranatsios@gmail.com>
 *
 * Copyright (C) 2008-2011 NEC Corporation
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License, version 2, as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */


#include "ruby.h"
#include "trema.h"
#include "libpathresolver.h"


VALUE mPathResolverClient;
VALUE cPathResolverHop;
pathresolver *handle;


static VALUE
init_path_resolver_client( VALUE self ) {
  handle = create_pathresolver();
  return self;
}


#if 0
static VALUE
pathresolver_hop_init( VALUE kclass ) {
  pathresolver_hop *_pathresolver_hop = xmalloc( sizeof( pathresolver_hop ) );
  return Data_Wrap_Struct( klass, 0, xfree, _pathresolver_hop );
}
#endif


static VALUE
pathresolver_hop_alloc( VALUE kclass ) {
  pathresolver_hop *_pathresolver_hop = xmalloc( sizeof( pathresolver_hop ) );
  return Data_Wrap_Struct( kclass, 0, xfree, _pathresolver_hop );
}


static pathresolver_hop *
get_pathresolver_hop( VALUE self ) {
  pathresolver_hop *_pathresolver_hop;
  Data_Get_Struct( self, pathresolver_hop, _pathresolver_hop );
  return _pathresolver_hop;
}


static VALUE
pathresolver_hop_dpid( VALUE self ) {
  return ULL2NUM( get_pathresolver_hop( self )->dpid );
}


static VALUE
pathresolver_hop_in_port_no( VALUE self ) {
  return UINT2NUM( get_pathresolver_hop( self )->in_port_no );
}


static VALUE
pathresolver_hop_out_port_no( VALUE self ) {
  return UINT2NUM( get_pathresolver_hop( self )->out_port_no );
}


/*
 * Resolves a path to route a packet given an origin(in_dpid/in_port)
 * and a destination(out_dpid, out_port).
 *
 * @example
 *   path_resolve in_dpid, in_port, out_dpid, out_port
 *
 * @param [Number] in_dpid
 *   the origin identifier.
 *
 * @param [Number] in_port
 *   the input port which the packet_in is received.
 *
 * @param [Number] out_dpid
 *   the destination identifier.
 *
 * @param [Number] out_port
 *   the destination output port.
 *
 * @return [Array<PathResolverHop>]
 *   an array of PathResolverHop objects for each hop determined.
 *
 * @return [NilClass] nil if path determination failed.
 *
 */
static VALUE
path_resolve( VALUE self, VALUE in_dpid, VALUE in_port, VALUE out_dpid, VALUE out_port  ) {
  UNUSED( self );

  if ( handle != NULL ) {
    dlist_element *hops = resolve_path( handle, NUM2ULL( in_dpid ), ( uint16_t ) NUM2UINT( in_port ), NUM2ULL( out_dpid ), ( uint16_t ) NUM2UINT( out_port ) );
    if ( hops != NULL ) {
      VALUE pathresolver_hops_arr = rb_ary_new();
      for ( dlist_element *e = hops; e != NULL; e = e->next ) {
        VALUE message = rb_funcall( cPathResolverHop, rb_intern( "new" ), 0 );
        pathresolver_hop *tmp = NULL;
        Data_Get_Struct( message, pathresolver_hop, tmp );
        memcpy( tmp, e->data,  sizeof( pathresolver_hop ) );
        rb_ary_push( pathresolver_hops_arr, message );
      }
      return pathresolver_hops_arr;
    }
    else {
      return Qnil;
    }
  }
  return Qnil;
}


/*
 * Updates the status of a node based on the given topology link status message.
 *
 * @param [topology_link_status] message
 *   the message that describes the topology link status.
 * @return [void]
 */
static VALUE
update_path( VALUE self, VALUE message ) {
  topology_link_status *_topology_link_status;
  Data_Get_Struct( message, topology_link_status, _topology_link_status );
  update_topology( handle, _topology_link_status );
  return self;
}


void
Init_path_resolver_client() {
  mPathResolverClient = rb_define_module( "PathResolverClient" );
  cPathResolverHop = rb_define_class_under( mPathResolverClient, "HopInfo", rb_cObject );
  rb_define_alloc_func( cPathResolverHop, pathresolver_hop_alloc );
#if 0
  rb_define_method( cPathResolverHop "initialize", pathresolver_hop_init, 0 );
#endif
  rb_define_method( cPathResolverHop, "dpid", pathresolver_hop_dpid, 0 );
  rb_define_method( cPathResolverHop, "in_port_no", pathresolver_hop_in_port_no, 0 );
  rb_define_method( cPathResolverHop, "out_port_no", pathresolver_hop_out_port_no, 0 );

  rb_define_method( mPathResolverClient, "init_path_resolver_client", init_path_resolver_client, 0 );
  rb_define_method( mPathResolverClient, "path_resolve", path_resolve, 4 );
  rb_define_method( mPathResolverClient, "update_path", update_path, 1 );
}


/*
 * Local variables:
 * c-basic-offset: 2
 * indent-tabs-mode: nil
 * End:
 */