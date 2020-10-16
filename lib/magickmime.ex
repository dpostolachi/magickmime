defprotocol Magickmime do
  @spec guess(binary) :: binary | {:error, <<_::192, _::_*32>>}
  def guess(value)

  @spec is?(binary, binary | [ binary ]) :: boolean
  def is?(value, targets)
end
