defimpl Magickmime.MimeProto, for: BitString  do

  # Images

  @images_mimes [
    png: "image/png",
    webp: "image/webp",
    gif: "image/gif",
    tiff: "image/tiff",
    jpg: "image/jpeg",
  ]

  @images_ascii_magicks [

    { "PNG", @image_mimes[ :png ] },

    { "WEBP", @image_mimes[ :webp ] },
    { "RIFF", @image_mimes[ :webp ] },

    { "GIF87a", @image_mimes[ :webp ] },
    { "GIF89a", @image_mimes[ :gif ] },

    { "ÿØÿÛ", @image_mimes[ :jpg ] },
    { "ÿØÿà", @image_mimes[ :jpg ] },
    { "ÿØÿî", @image_mimes[ :jpg ] },
    { "ÿØÿá", @image_mimes[ :jpg ] },

    { "BM", @image_mimes[ :bmp ] },

    { "II*", @image_mimes[ :tiff ] },
    { "MM.*", @image_mimes[ :tiff ] },
  ]

  def mime( bitstring ) do
    :png
  end

end
