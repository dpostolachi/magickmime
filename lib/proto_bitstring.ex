defimpl Magickmime, for: BitString  do

  # https://www.garykessler.net/library/file_sigs.html
  # https://en.wikipedia.org/wiki/List_of_file_signatures

  # Max byte pattern
  @max_size 12
  @accepted_types [ :image, :audio, :video ]

  # Truncate incoming bitstring
  def mime( type, bitstring )
    when
      is_binary( bitstring ) and
      byte_size( bitstring ) > @max_size,
    do: mime( type, :binary.part( bitstring, 0, @max_size ) )

  # Images:
  def mime( :image, <<0x89, 0x50, 0x4E, 0x47, 0xD, 0xA, 0x1A, 0xA >> <> _rest ),                              do: :png
  # Not sure about the 2nd 0xFF
  def mime( :image, <<0xFF, 0xD8, 0xFF>> <> _rest ),                                                          do: :jpeg
  def mime( :image, <<0x47, 0x49, 0x46, 0x38, 0x37, 0x61>> <> _rest ),                                        do: :gif
  def mime( :image, <<0x47, 0x49, 0x46, 0x38, 0x39, 0x61>> <> _rest ),                                        do: :gif
  def mime( :image, <<0x52, 0x49, 0x46, 0x46, _, _, _, _, 0x57, 0x45, 0x42, 0x50>> <> _rest ),                do: :webp
  def mime( :image, <<0x49, 0x49, 0x2A, 0x00>> <> _rest ),                                                    do: :tiff
  def mime( :image, <<0x4D, 0x4D, 0x00, 0x2A>> <> _rest ),                                                    do: :tiff
  def mime( :image, <<0x42, 0x4D>> <> _rest ),                                                                do: :bmp

  # Audio
  def mime( :audio, <<0xFF, 0xFB>> <> _rest ),                                                                do: :mp3
  def mime( :audio, <<0xFF, 0xF3>> <> _rest ),                                                                do: :mp3
  def mime( :audio, <<0xFF, 0xF2>> <> _rest ),                                                                do: :mp3
  def mime( :audio, <<0x49, 0x44, 0x33>> <> _rest ),                                                          do: :mp3
  def mime( :audio, <<0x66, 0x4C, 0x61, 0x43>> <> _rest ),                                                    do: :flac
  def mime( :audio, <<0x52, 0x49, 0x46, 0x46, _, _, _, _, 0x57, 0x41, 0x56, 0x45>> <> _rest ),                do: :wav

  # Video
  def mime( :video, <<0x00, 0x00, 0x00, 0x18, 0x66, 0x74, 0x79, 0x70, 0x69, 0x73, 0x6F, 0x6D>> <> _rest ),    do: :mp4
  def mime( :video, <<_,_,_,_, 0x66, 0x74, 0x79, 0x70>> <> _rest ),                                           do: :mov
  def mime( :video, <<0x30, 0x26, 0xB2, 0x75, 0x8E, 0x66, 0xCF, 0x11>> <> _rest ),                            do: :wmv
  def mime( :video, <<0x52, 0x49, 0x46, 0x46, _, _, _, _, 0x41, 0x56, 0x49, 0x20>> <> _rest ),                do: :avi
  # Counts mkv, mka, mks, mk3d and webm
  def mime( :video, <<0x1A, 0x45, 0xDF, 0xA3>> <> _rest ),                                                    do: :webm

  # Type in @accepted_types, but couldn't find the mime type
  @not_found "couldn't determine mime type"
  def mime( type, _ ) when type in @accepted_types, do: { :error, @not_found }

  # Media type not in @accepted_types
  @not_accepted "media type not supported"
  def mime( _, _ ), do: { :error, @not_accepted }

  # Check against all types
  def mime( bitstring ) when is_binary( bitstring ) do
    with  { :error, _mess } <- mime( :image, bitstring ),
          { :error, _mess } <- mime( :video, bitstring ),
          { :error, mess } <- mime( :audio, bitstring )
    do
      { :error, mess }
    else
      mime_type ->
        mime_type
    end
  end

end
