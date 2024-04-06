defimpl Magickmime, for: BitString  do

  # https://www.garykessler.net/library/file_sigs.html
  # https://en.wikipedia.org/wiki/List_of_file_signatures

  @accepted_types [ :image, :audio, :video ]
  @max_size 12

  # Images:
  @mimes %{
    :png => "image/png",
    :jpeg => "image/jpeg",
    :gif => "image/gif",
    :webp => "image/webp",
    :tiff => "image/tiff",
    :bmp => "image/bmp",
    :avif => "image/avif",
  }

  defp match_mime( :image, <<0x89, 0x50, 0x4E, 0x47, 0xD, 0xA, 0x1A, 0xA >> <> _rest ),                  do: :png
  # Not sure about the 2nd 0xFF
  defp match_mime( :image, <<0xFF, 0xD8, 0xFF>> <> _rest ),                                              do: :jpeg
  defp match_mime( :image, <<0x47, 0x49, 0x46, 0x38, 0x37, 0x61>> <> _rest ),                            do: :gif
  defp match_mime( :image, <<0x47, 0x49, 0x46, 0x38, 0x39, 0x61>> <> _rest ),                            do: :gif
  defp match_mime( :image, <<0x52, 0x49, 0x46, 0x46, _, _, _, _, 0x57, 0x45, 0x42, 0x50>> <> _rest ),    do: :webp
  defp match_mime( :image, <<0x49, 0x49, 0x2A, 0x00>> <> _rest ),                                        do: :tiff
  defp match_mime( :image, <<0x4D, 0x4D, 0x00, 0x2A>> <> _rest ),                                        do: :tiff
  defp match_mime( :image, <<0x42, 0x4D>> <> _rest ),                                                    do: :bmp
  defp match_mime( :image, <<_, _, _, _, 0x66, 0x74, 0x79, 0x70, 0x61, 0x76, 0x69, 0x66>> <> _rest ),     do: :avif

  # Audio
  @mimes Map.merge( @mimes, %{
    :mp3 => "audio/mpeg",
    :flac => "audio/flac",
    :wav => "audio/wav",
  } )

  defp match_mime( :audio, <<0xFF, 0xFB>> <> _rest ),                                                    do: :mp3
  defp match_mime( :audio, <<0xFF, 0xF3>> <> _rest ),                                                    do: :mp3
  defp match_mime( :audio, <<0xFF, 0xF2>> <> _rest ),                                                    do: :mp3
  defp match_mime( :audio, <<0x49, 0x44, 0x33>> <> _rest ),                                              do: :mp3
  defp match_mime( :audio, <<0x66, 0x4C, 0x61, 0x43>> <> _rest ),                                        do: :flac
  defp match_mime( :audio, <<0x52, 0x49, 0x46, 0x46, _, _, _, _, 0x57, 0x41, 0x56, 0x45>> ),             do: :wav

  # Video
  @mimes Map.merge( @mimes, %{
    :mp4 => "video/mp4",
    :flac => "video/quicktime",
    :wmv => "video/x-ms-wmv",
    :avi => "video/x-msvideo",
    :webm => "video/webm",
  } )
  defp match_mime( :video, <<0x00, 0x00, 0x00, 0x18, 0x66, 0x74, 0x79, 0x70, 0x69, 0x73, 0x6F, 0x6D>> ), do: :mp4
  defp match_mime( :video, <<_,_,_,_, 0x66, 0x74, 0x79, 0x70>> <> _rest ),                               do: :mov
  defp match_mime( :video, <<0x30, 0x26, 0xB2, 0x75, 0x8E, 0x66, 0xCF, 0x11>> <> _rest ),                do: :wmv
  defp match_mime( :video, <<0x52, 0x49, 0x46, 0x46, _, _, _, _, 0x41, 0x56, 0x49, 0x20>> <> _rest ),    do: :avi
  # Counts mkv, mka, mks, mk3d and webm
  defp match_mime( :video, <<0x1A, 0x45, 0xDF, 0xA3>> <> _rest ),                                        do: :webm

  @not_found "couldn't determine mime type"
  @not_accepted "media type not supported"

  defp match_mime( type, _ ) when type in @accepted_types, do: { :error, @not_found }
  defp match_mime( _, _ ), do: { :error, @not_accepted }

  @spec guess(atom, binary) :: binary | {:error, <<_::192, _::_*32>>}
  def guess( type, bitstring )
    when is_binary( bitstring )
    and byte_size( bitstring ) > @max_size,
  do: guess( type, :binary.part( bitstring, 0, @max_size ) )

  def guess( type, bitstring ) when is_binary( bitstring ) do
    case match_mime( type, bitstring )  do
      atom_mime when is_atom( atom_mime ) -> @mimes[ atom_mime ]
      err -> err
    end
  end

  @spec guess(binary) :: binary | {:error, <<_::192, _::_*32>>}
  def guess( bitstring )
    when is_binary( bitstring )
    and byte_size( bitstring ) > @max_size,
  do: guess( :binary.part( bitstring, 0, @max_size ) )

  def guess( bitstring ) when is_binary( bitstring ) do
    with  { :error, _mess } <- guess( :image, bitstring ),
          { :error, _mess } <- guess( :video, bitstring ),
          { :error, mess } <- guess( :audio, bitstring )
    do
      { :error, mess }
    else
      mime_type ->
        mime_type
    end
  end

  def matches?( source, targets ) when is_list( targets ),
    do: Enum.any?( targets, fn target -> matches?( source, target ) end )

  def matches?( source, target ) when is_binary( source ) and is_binary( target ) do
    with [ source_type, source_sub_type ] <- String.split( source, "/" ),
        [ target | _ ] <- String.split( target, ";" ), # Remove q-factor
        [ target_type, target_sub_type ] <- String.split( target, "/" )
    do
      case target_sub_type do
          # type/*
          "*" -> target_type == source_type
          # type/sub_type
          _ ->
            case target_type do
                # */*
                "*" -> true
                # type/sub_type
                _ ->
                  target_type == source_type &&
                  target_sub_type == source_sub_type
            end
      end
    else
      _ ->
          false
    end
  end

  @spec is?(binary, binary | [ binary ]) :: boolean
  def is?( bitstring, target ) do
    case guess( bitstring ) do
      { :error, _ } ->
        false
      mime_type when is_binary( mime_type ) ->
        matches?( mime_type, target )
    end
  end

end
