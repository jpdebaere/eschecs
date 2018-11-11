{
 /**************************************************************************\
                                bgrabitmap.pas
                                --------------
                 Free easy-to-use memory bitmap 32-bit,
                 8-bit for each channel, transparency.
                 Channels can be in the following orders:
                 - B G R A (recommended for Windows, required for fpGUI)
                 - R G B A (recommended for Gtk and MacOS)

                 - Drawing primitives
                 - Resample
                 - Reference counter
                 - Drawing on LCL canvas
                 - Loading and saving images

                 Note : line order can change, so if you access
                 directly to bitmap data, check LineOrder value
                 or use Scanline to compute position.


       --> Include BGRABitmap and BGRABitmapTypes in the 'uses' clause.

 ****************************************************************************
 *                                                                          *
 *  This file is part of BGRABitmap library which is distributed under the  *
 *  modified LGPL.                                                          *
 *                                                                          *
 *  See the file COPYING.modifiedLGPL.txt, included in this distribution,   *
 *  for details about the copyright.                                        *
 *                                                                          *
 *  This program is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                    *
 *                                                                          *
 ****************************************************************************
}

unit BGRABitmap;

{$mode objfpc}{$H+}
{$i bgrabitmap.inc}

interface

{ Compiler directives are used to include the best version according
  to the platform }

uses
  Classes, SysUtils,
{$IFDEF BGRABITMAP_USE_FPGUI}
    BGRAfpGUIBitmap,
{$ELSE}
	{$IFDEF BGRABITMAP_USE_LCL}
	  {$IFDEF LCLwin32}
		BGRAWinBitmap,
	  {$ELSE}
		{$IFDEF LCLgtk}
		BGRAGtkBitmap,
		{$ELSE}
		  {$IFDEF LCLgtk2}
		BGRAGtkBitmap,
		  {$ELSE}
			{$IFDEF LCLqt}
		BGRAQtBitmap,
			{$ELSE}
      {$IFDEF LCLQT5}   //=== ct9999 =====
    BGRAQt5Bitmap,
      {$ELSE}                        
      {$IFDEF DARWIN}
    BGRAMacBitmap,
      {$ELSE}
		BGRALCLBitmap,
			{$ENDIF}
      {$ENDIF}
		  {$ENDIF}
		  {$ENDIF}
		{$ENDIF}
	  {$ENDIF}
	{$ELSE}
	  BGRANoGuiBitmap,
	{$ENDIF}
{$ENDIF}
  BGRAGraphics;

type
{$IFDEF BGRABITMAP_USE_FPGUI}
  TBGRABitmap = class(TBGRAfpGUIBitmap);
{$ELSE}
    {$IFDEF BGRABITMAP_USE_LCL}
      {$IFDEF LCLwin32}
        TBGRABitmap = class(TBGRAWinBitmap);
      {$ELSE}
        {$IFDEF LCLgtk}
        TBGRABitmap = class(TBGRAGtkBitmap);
        {$ELSE}
          {$IFDEF LCLgtk2}
        TBGRABitmap = class(TBGRAGtkBitmap);
          {$ELSE}
            {$IFDEF LCLqt}
        TBGRABitmap = class(TBGRAQtBitmap);
            {$ELSE}
            {$IFDEF LCLQT5}   //=== ct9999 =====
        TBGRABitmap = class(TBGRAQtBitmap);
            {$ELSE}
            {$IFDEF DARWIN}
        TBGRABitmap = class(TBGRAMacBitmap);
            {$ELSE}
        TBGRABitmap = class(TBGRALCLBitmap);
            {$ENDIF}
          {$ENDIF}
          {$ENDIF}
          {$ENDIF}
        {$ENDIF}
      {$ENDIF}
    {$ELSE}
      TBGRABitmap = class(TBGRANoGUIBitmap);
    {$ENDIF}
{$ENDIF}

// draw a bitmap from pure data
procedure BGRABitmapDraw(ACanvas: TCanvas; Rect: TRect; AData: Pointer;
  VerticalFlip: boolean; AWidth, AHeight: integer; Opaque: boolean);
  
{ Replace the content of the variable Destination with the variable
  Temp and frees previous object contained in Destination.
  
  This function is useful as a shortcut for :
 
  var
    temp: TBGRABitmap;
  begin
    ...
    temp := someBmp.Filter... as TBGRABitmap;
    someBmp.Free;
    someBmp := temp;
  end;
  
  which becomes :
  
  begin
    ...
    BGRAReplace(someBmp, someBmp.Filter... );
  end;
}
procedure BGRAReplace(var Destination: TBGRABitmap; Temp: TObject);

implementation

uses BGRABitmapTypes, BGRAReadBMP, BGRAReadBmpMioMap, BGRAReadGif,
  BGRAReadIco, BGRAReadJpeg, BGRAReadLzp, BGRAReadPCX,
  BGRAReadPng, BGRAReadPSD, BGRAReadTGA, BGRAReadXPM,
  BGRAWriteLzp;

var
  tempBmp: TBGRABitmap;

procedure BGRABitmapDraw(ACanvas: TCanvas; Rect: TRect; AData: Pointer;
  VerticalFlip: boolean; AWidth, AHeight: integer; Opaque: boolean);
var
  LineOrder: TRawImageLineOrder;
begin
  if tempBmp = nil then
    tempBmp := TBGRABitmap.Create;
  if VerticalFlip then
    LineOrder := riloBottomToTop
  else
    LineOrder := riloTopToBottom;
  if Opaque then
    tempBmp.DataDrawOpaque(ACanvas, Rect, AData, LineOrder, AWidth, AHeight)
  else
    tempBmp.DataDrawTransparent(ACanvas, Rect, AData, LineOrder, AWidth, AHeight);
end;

procedure BGRAReplace(var Destination: TBGRABitmap; Temp: TObject);
begin
  Destination.Free;
  Destination := Temp as TBGRABitmap;
end;

initialization

  //this variable is assigned to access appropriate functions
  //depending on the platform
  BGRABitmapFactory := TBGRABitmap;

finalization

  tempBmp.Free;

end.

