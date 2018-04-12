/*
* Copyright (c) 2018 (https://github.com/phase1geo/Minder)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Trevor Williams <phase1geo@gmail.com>
*/

using GLib;

public class OPML : Object {

  /* Exports the given drawing area to the file of the given name */
  public static bool export( string fname, DrawArea da ) {
    Xml.Doc*  doc  = new Xml.Doc( "1.0" );
    Xml.Node* opml = new Xml.Node( null, "opml" );
    string    expand_state;
    Xml.Node* body = export_body( da, out expand_state );
    opml->new_prop( "version", "2.0" );
    opml->add_child( export_head( Path.get_basename( fname ), expand_state ) );
    opml->add_child( body );
    doc->set_root_element( opml );
    doc->save_format_file( fname, 1 );
    delete doc;
    return( true );
  }

  /* Generates the header for the document */
  private static Xml.Node* export_head( string? title, string expand_state ) {
    Xml.Node* head = new Xml.Node( null, "head" );
    var now  = new DateTime.now_local();
    head->new_text_child( null, "title", (title ?? "Mind Map") );
    head->new_text_child( null, "dateCreated", now.to_string() );
    if( expand_state != "" ) {
      head->new_text_child( null, "expansionState", expand_state );
    }
    return( head );
  }

  /* Generates the body for the document */
  private static Xml.Node* export_body( DrawArea da, out string expand_state ) {
    Xml.Node* body = new Xml.Node( null, "body" );
    da.export_opml( body, out expand_state );
    return( body );
  }

  /*
   Reads the contents of an OPML file and creates a new document based on
   the stored information.
  */
  public static bool import( string fname ) {
    
    /* Read in the contents of the OPML file */
    var doc = Xml.Parser.parse_file( fname );
    if( doc == null ) {
      return( false );
    }
    
    /* Load the contents of the file */
    for( Xml.Node* it = n->children; it != null; it = it->next ) {
      if( it->type == Xml.ElementType.ELEMENT_NODE ) {
        Array<int>? expand_state = null;
        switch( it->name ) {
          case "head" :
            import_header( it, out expand_state );
            break;
          case "body" :
            da.import_opml( it, expand_state );
            break;
        }
      }
    }
 
    /* Delete the OPML document */
    delete doc;
    
    return( true );
    
  }
 
  /* Parses the OPML head block for information that we will use */ 
  private static void import_header( Xml.Node* n, out Array<int>? expand_state ) {
    for( Xml.Node* it = n->children; it != null; it = it->next ) {
      if( it->type == Xml.ElementType.ELEMENT_NODE ) {
        switch( it->name ) {
          case "expansionState" :
            if( (it->children != null) && (it->children->type == Xml.ElementType.TEXT_NODE) ) {
              expand_state = new Array<int>();
              string[] values = n->children->get_content().split( "," );
              foreach (string val in values) {
                expand_state.append_val( val.to_int() );
              }
            }
            break;
          }
        }
      }
    }
  }

}
