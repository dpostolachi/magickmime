defprotocol Magickmime do
  @spec guess(binary) :: binary | {:error, <<_::192, _::_*32>>}
  def guess(value)

  @spec is?(binary, binary | [ binary ]) :: boolean
  def is?(binary, target_mime_types)

  @spec matches?(binary, binary | [ binary ]) :: boolean
  def matches?(mime_type, target_mime_types)
end
