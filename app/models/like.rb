class Like < ActsAsVotable::Vote
  UPDATABLE_COLUMNS = [:votable_id, :votable_type, :voter_id]
end
