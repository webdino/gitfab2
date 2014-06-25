# require "spec_helper"
# 
# describe DerivativeCardsController, type: :controller do
#   disconnect_sunspot
#   render_views
#
#   let(:project){FactoryGirl.create :user_project}
#   let(:user){project.owner}
#   let(:state){project.recipe.recipe_cards.create _type: Card::State.name, description: "foo"}
#
#   subject{response}
#
#   describe "GET new" do
#     before do
#       xhr :get, :new, owner_name: user.id, project_id: project.id,
#         state_id: state.id
#     end
#     it{should render_template :new}
#   end
#
#   describe "GET edit" do
#     before do
#       derivative = state.derivatives.create description: "der"
#       xhr :get, :edit, owner_name: user.id, project_id: project.id,
#         state_id: state.id, id: derivative.id
#     end
#     it{should render_template :edit}
#   end
#
#   describe "POST create" do
#     before do
#       xhr :post, :create, user_id: user.id, project_id: project.id,
#         state_id: state.id, derivative: {description: "der"}
#       state.reload
#     end
#     it{should render_template :create}
#     it{expect(state).to have(1).derivative}
#   end
#
#   describe "PATCH update" do
#     before do
#       derivative = state.derivatives.create description: "der"
#       xhr :patch, :update, user_id: user.id, project_id: project.id,
#         state_id: state.id, id: derivative.id, derivative: {description: "_der"}
#       state.reload
#     end
#     it{should render_template :update}
#   end
#
#   describe "DELETE destroy" do
#     before do
#       derivative = state.derivatives.create description: "der"
#       xhr :delete, :destroy, owner_name: user.id, project_id: project.id,
#         state_id: state.id, id: derivative.id
#       state.reload
#     end
#     it{should render_template :destroy}
#     it{expect(state).to have(0).derivative}
#   end
# end
