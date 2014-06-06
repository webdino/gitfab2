class Card::Memo < Card
  embedded_in :note

  field :title
end
