json.id @member.id
json.html (render "groups/membership", membership: @member.membership_in(@group))
