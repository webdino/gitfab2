json.id @membership.id
json.role @membership.role
json.html (render 'groups/membership', membership: @membership)
