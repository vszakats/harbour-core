/*
 * Document generator - HTML output
 *
 * Copyright 2009 April White <bright.tigra gmail.com>
 * Copyright 1999-2003 Luiz Rafael Culik <culikr@uol.com.br> (Portions of this project are based on hbdoc)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.txt.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site https://www.gnu.org/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

#include "hbclass.ch"

#define EXTENSION  ".html"

#define STYLEFILE  "hbdoc.css"

CREATE CLASS GenerateHTML2 INHERIT GenerateHTML

   METHOD NewIndex( cDir, cFilename, cTitle )
   METHOD NewDocument( cDir, cFilename, cTitle )

ENDCLASS

METHOD NewDocument( cDir, cFilename, cTitle ) CLASS GenerateHTML2

   ::super:NewDocument( cDir, cFilename, cTitle, EXTENSION )

   RETURN self

METHOD NewIndex( cDir, cFilename, cTitle ) CLASS GenerateHTML2

   ::super:NewIndex( cDir, cFilename, cTitle, EXTENSION )

   RETURN self

CREATE CLASS GenerateHTML INHERIT TPLGenerate

   HIDDEN:

   METHOD RecreateStyleDocument( cStyleFile )
   METHOD OpenTagInline( cText, ... )
   METHOD OpenTag( cText, ... )
   METHOD Tagged( cText, cTag, ... )
   METHOD CloseTagInline( cText )
   METHOD CloseTag( cText )
   METHOD AppendInline( cText, cFormat, lCode )
   METHOD Append( cText, cFormat, lCode )
   METHOD Space() INLINE hb_vfWrite( ::hFile, ", " ), self
   METHOD Spacer() INLINE hb_vfWrite( ::hFile, hb_eol() ), self
   METHOD Newline() INLINE hb_vfWrite( ::hFile, "<br>" + hb_eol() ), self

   CLASS VAR lCreateStyleDocument AS LOGICAL INIT .T.
   VAR TargetFilename AS STRING INIT ""

   EXPORTED:

   METHOD NewFile() HIDDEN
   METHOD NewIndex( cDir, cFilename, cTitle )
   METHOD NewDocument( cDir, cFilename, cTitle )
   METHOD AddEntry( oEntry )
   METHOD AddReference( oEntry, cReference, cSubReference )
   METHOD BeginSection( cSection, cFilename )
   METHOD EndSection( cSection, cFilename )
   METHOD Generate()

   METHOD WriteEntry( cField, oEntry, lPreformatted ) HIDDEN

ENDCLASS

METHOD NewFile() CLASS GenerateHTML

   hb_vfWrite( ::hFile, "<!DOCTYPE html>" + hb_eol() )

   ::OpenTag( "html", "lang", "en" )
   ::Spacer()

   ::OpenTag( "meta", "charset", "utf-8" )
   ::OpenTag( "meta", "name", "generator", "content", "hbdoc" )
   ::OpenTag( "meta", "name", "keywords", "content", "Harbour, Clipper, xBase, database, Free Software, GPL, compiler, cross platform, 32-bit, 64-bit" )
   ::Spacer()

   IF ::lCreateStyleDocument
      ::lCreateStyleDocument := .F.
      ::RecreateStyleDocument( STYLEFILE )
   ENDIF

   ::Append( ::cTitle /* + iif( Empty( ::cDescription ), "", " - " + ::cDescription ) */, "title" )
   ::Spacer()

   ::OpenTag( "link", "rel", "stylesheet", "href", STYLEFILE )
   ::Spacer()

   ::OpenTag( "body" )
   ::Spacer()

   ::OpenTag( "header" )
   ::Append( ::cTitle, "h1" )
   ::CloseTag( "header" )
   ::Spacer()

   ::OpenTag( "main" )

   RETURN self

METHOD Generate() CLASS GenerateHTML

   ::Spacer()
   ::CloseTag( "main" )

   RETURN self

METHOD NewDocument( cDir, cFilename, cTitle ) CLASS GenerateHTML

   ::super:NewDocument( cDir, cFilename, cTitle, EXTENSION )
   ::NewFile()

   RETURN self

METHOD NewIndex( cDir, cFilename, cTitle ) CLASS GenerateHTML

   ::super:NewIndex( cDir, cFilename, cTitle, EXTENSION )
   ::NewFile()

   RETURN self

METHOD BeginSection( cSection, cFilename ) CLASS GenerateHTML

   cSection := SymbolToHTMLID( cSection )

   IF ::IsIndex()
      IF cFilename == ::cFilename
         ::OpenTagInline( "div", "id", cSection ):AppendInline( cSection, "h" + hb_ntos( ::Depth + 2 ) ):CloseTag( "div" )
      ELSE
         ::OpenTag( "a", "href", cFilename + ::cExtension + "#" + cSection ):Append( cSection, "h" + hb_ntos( ::Depth + 2 ) ):CloseTag( "a" )
      ENDIF
   ELSE
      ::OpenTagInline( "div", "id", cSection ):AppendInline( cSection, "h" + hb_ntos( ::Depth + 2 ) ):CloseTag( "div" )
   ENDIF
   ::TargetFilename := cFilename
   ::Depth++

   RETURN self

METHOD EndSection( cSection, cFilename ) CLASS GenerateHTML

   HB_SYMBOL_UNUSED( cSection )
   HB_SYMBOL_UNUSED( cFilename )
   ::Depth--

   RETURN self

METHOD AddReference( oEntry, cReference, cSubReference ) CLASS GenerateHTML

   IF HB_ISOBJECT( oEntry ) .AND. oEntry:ClassName() == "ENTRY"
      ::OpenTag( "a", "href", ::TargetFilename + ::cExtension + "#" + oEntry:Filename ):Append( oEntry:Name ):CloseTag( "a" ):Append( oEntry:OneLiner ):Newline()
   ELSE
      IF HB_ISSTRING( cSubReference )
         ::OpenTag( "a", "href", cReference + ::cExtension + "#" + cSubReference ):Append( oEntry ):CloseTag( "a" ):Newline()
      ELSE
         ::OpenTag( "a", "href", cReference + ::cExtension /* + "#" + oEntry:Filename */ ):Append( oEntry ):CloseTag( "a" ):Newline()
      ENDIF
   ENDIF

   RETURN self

METHOD AddEntry( oEntry ) CLASS GenerateHTML

   LOCAL item
   LOCAL cEntry

   ::Spacer()
   ::OpenTag( "section", "id", SymbolToHTMLID( oEntry:filename ) )

   FOR EACH item IN oEntry:Fields
      IF item[ 1 ] == "NAME"
         cEntry := oEntry:Name
         IF "(" $ cEntry .OR. Upper( cEntry ) == cEntry  // guess if it's code
            ::OpenTagInline( "h4" ):OpenTagInline( "code" ):AppendInline( cEntry ):CloseTagInline( "code" ):CloseTag( "h4" )
         ELSE
            ::OpenTagInline( "h4" ):AppendInline( cEntry ):CloseTag( "h4" )
         ENDIF
      ELSEIF oEntry:IsField( item[ 1 ] ) .AND. oEntry:IsOutput( item[ 1 ] ) .AND. Len( oEntry:&( item[ 1 ] ) ) > 0
         ::WriteEntry( item[ 1 ], oEntry, oEntry:IsPreformatted( item[ 1 ] ) )
      ENDIF
   NEXT

   ::CloseTag( "section" )

   RETURN self

METHOD PROCEDURE WriteEntry( cField, oEntry, lPreformatted ) CLASS GenerateHTML

   STATIC s_class := { ;
      "name"     => "d-na", ;
      "oneliner" => "d-ol", ;
      "examples" => "d-ex", ;
      "tests"    => "d-te" }

   LOCAL cCaption := oEntry:FieldName( cField )
   LOCAL cEntry := oEntry:&( cField )
   LOCAL lFirst
   LOCAL tmp, tmp1

   /* TODO: change this to search the CSS document itself */
   LOCAL cTagClass := hb_HGetDef( s_class, Lower( cField ), "d-it" )

   IF ! Empty( cEntry )

#if 0
      hb_default( @lPreformatted, .F. )
      hb_default( @cTagClass, "d-it" )
#endif

      hb_default( @cCaption, "" )
      IF ! HB_ISNULL( cCaption )
         ::Tagged( cCaption, "div", "class", "d-d" )
      ENDIF

      IF lPreformatted
         ::OpenTag( "pre", "class", cTagClass )
         DO WHILE ! HB_ISNULL( cEntry )
            IF Lower( cField ) + "|" $ "examples|tests|"
               ::Append( SubStr( Parse( @cEntry, hb_eol() ), 5 ), "", .T. )
            ELSE
               ::Append( Indent( Parse( @cEntry, hb_eol() ), 0, , .T. ), "", .T. )
            ENDIF
#if 0
            IF ! HB_ISNULL( cEntry ) .AND. ! lPreformatted
               hb_vfWrite( ::hFile, hb_eol() )
            ENDIF
#endif
         ENDDO
         ::CloseTag( "pre" )
      ELSE
         DO WHILE ! HB_ISNULL( cEntry )

            SWITCH Lower( cField )
            CASE "syntax"
               ::OpenTagInline( "div", "class", cTagClass )
               ::OpenTagInline( "code" )
               ::AppendInline( Indent( Parse( @cEntry, hb_eol() ), 0, 70,, .T. ), "", .F. )
               ::CloseTagInline( "code" )
               EXIT
            CASE "oneliner"
               ::OpenTagInline( "div", "class", cTagClass )
               ::AppendInline( Indent( Parse( @cEntry, hb_eol() ), 0, 70,, .T. ), "" )
               EXIT
            CASE "seealso"
               ::OpenTagInline( "div", "class", cTagClass )
               lFirst := .T.
               FOR EACH tmp IN hb_ATokens( cEntry, "," )
                  tmp := AllTrim( tmp )
                  IF ! HB_ISNULL( tmp )
                     // TOFIX: for multi-file output
                     tmp1 := Parse( tmp, "(" )
                     IF lFirst
                        lFirst := .F.
                     ELSE
                        ::Space()
                     ENDIF
                     ::OpenTagInline( "code" ):OpenTagInline( "a", "href", "#" + SymbolToHTMLID( tmp1 ) ):AppendInline( tmp ):CloseTagInline( "a" ):CloseTagInline( "code" )
                  ENDIF
               NEXT
               cEntry := ""
               EXIT
            OTHERWISE
               ::OpenTagInline( "div", "class", cTagClass )
               ::AppendInline( Indent( Parse( @cEntry, hb_eol() ), 0, 70,, .T. ), "" )
            ENDSWITCH

            ::CloseTag( "div" )
         ENDDO
      ENDIF
   ENDIF

   RETURN

METHOD OpenTagInline( cText, ... ) CLASS GenerateHTML

   LOCAL aArgs := hb_AParams()
   LOCAL idx

   FOR idx := 2 TO Len( aArgs ) STEP 2
      cText += " " + aArgs[ idx ] + "=" + '"' + aArgs[ idx + 1 ] + '"'
   NEXT

   hb_vfWrite( ::hFile, "<" + cText + ">" )

   RETURN self

METHOD OpenTag( cText, ... ) CLASS GenerateHTML

   ::OpenTagInline( cText, ... )

   hb_vfWrite( ::hFile, hb_eol() )

   RETURN self

METHOD Tagged( cText, cTag, ... ) CLASS GenerateHTML

   LOCAL aArgs := hb_AParams()
   LOCAL cResult := ""
   LOCAL idx

   FOR idx := 3 TO Len( aArgs ) STEP 2
      cResult += " " + aArgs[ idx ] + "=" + '"' + aArgs[ idx + 1 ] + '"'
   NEXT

   hb_vfWrite( ::hFile, "<" + cTag + cResult + ">" + cText + "</" + cTag + ">" + hb_eol() )

   RETURN self

METHOD CloseTagInline( cText ) CLASS GenerateHTML

   hb_vfWrite( ::hFile, "</" + cText + ">" )

   IF cText == "html"
      hb_vfClose( ::hFile )
      ::hFile := NIL
   ENDIF

   RETURN self

METHOD CloseTag( cText ) CLASS GenerateHTML

   hb_vfWrite( ::hFile, "</" + cText + ">" + hb_eol() )

   IF cText == "html"
      hb_vfClose( ::hFile )
      ::hFile := NIL
   ENDIF

   RETURN self

METHOD AppendInline( cText, cFormat, lCode ) CLASS GenerateHTML

   STATIC s_html := { ;
      "&" => "&amp;", ;
      '"' => "&quot;", ;
      "<" => "&lt;", ;
      ">" => "&gt;" }

   STATIC s_htmlall := { ;
      "==>" => "&rarr;", ;
      "-->" => "&rarr;", ;
      "->" => "&rarr;", ;  /* valid Harbour code */
      "&" => "&amp;", ;
      '"' => "&quot;", ;
      "<" => "&lt;", ;
      ">" => "&gt;" }

   LOCAL idx

   IF ! HB_ISNULL( cText )

      IF hb_defaultValue( lCode, .F. )
         cText := hb_StrReplace( cText, s_html )
      ELSE
         cText := hb_StrReplace( cText, s_htmlall )
      ENDIF

      FOR EACH idx IN hb_ATokens( hb_defaultValue( cFormat, "" ), "," ) DESCEND
         IF ! Empty( idx )
            cText := "<" + idx + ">" + cText + "</" + idx + ">"
         ENDIF
      NEXT

      DO WHILE Right( cText, Len( hb_eol() ) ) == hb_eol()
         cText := hb_StrShrink( cText, Len( hb_eol() ) )
      ENDDO

      hb_vfWrite( ::hFile, cText )
   ENDIF

   RETURN self

METHOD Append( cText, cFormat, lCode ) CLASS GenerateHTML

   ::AppendInline( cText, cFormat, lCode )
   hb_vfWrite( ::hFile, hb_eol() )

   RETURN self

METHOD RecreateStyleDocument( cStyleFile ) CLASS GenerateHTML

   LOCAL cString

   #pragma __streaminclude "hbdoc.css" | cString := %s

   IF ! hb_MemoWrit( ::cDir + hb_ps() + cStyleFile, cString )
      /* TODO: raise an error, could not create style file */
   ENDIF

   RETURN self

STATIC FUNCTION SymbolToHTMLID( cID )
   RETURN Lower( hb_StrReplace( cID, { ;
     "%" => "pct", ;
     "_" => "-", ;
     " " => "-" } ) )
