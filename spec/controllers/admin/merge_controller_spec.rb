require 'spec_helper'

describe Admin::ContentController do
render_views

  describe 'merge' do
    
    describe 'check if user is an admin or not' do      
      describe 'user is admin' do
        it 'should check set show_merge to true if the user is an admin' do
          Factory(:blog)
          #TODO delete this after remove fixture
          Profile.delete_all
          @user = Factory(:user, :text_filter => Factory(:markdown), :profile => Factory(:profile_admin, :label => Profile::ADMIN))
          @user.editor = 'simple'
          @user.save
          @article = Factory(:article)
          request.session = { :user => @user.id }
          put :edit, 'id' => @article.id
          assigns(:show_merge).should == true 
        end
      end
    end
      
    describe 'user is not an admin' do
      it 'should check set show_merge to true if the user is an admin' do
        Factory(:blog)
        #TODO delete this after remove fixture
        Profile.delete_all
        @user = Factory(:user, :text_filter => Factory(:markdown), :profile => Factory(:profile_publisher))
        @user.editor = 'simple'
        @user.save
        @article = Factory(:article)
        request.session = { :user => @user.id }
        put :edit, 'id' => @article.id
        assigns(:show_merge).should == false
      end
    end
  end
  
  describe 'calls merge method' do

    before do
      Factory(:blog)
      #TODO delete this after remove fixture
      @user = Factory(:user, :profile => Factory(:profile_admin, :label => Profile::ADMIN))
      request.session = { :user => @user.id }
    end    

    describe 'success' do
      it 'calls model method' do
        Article.stub(:find).and_return(@article = mock('Article', { :merge_with => true }))
        Article.should_receive(:find).with('1').and_return(@article)
        @article.should_receive(:merge_with).with('3').and_return(true)
        #assigns(:success).should == true
        post :merge, {:current => '1', :merge => '3'}
        flash[:notice].should == 'awesome'
        response.should redirect_to '/admin/content'
      end
    end
    
    describe 'fail' do
      it 'calls model method' do
        Article.stub(:find).and_return(@article = mock('Article', { :merge_with => false }))
        Article.should_receive(:find).with('1').and_return(@article)
        @article.should_receive(:merge_with).with(nil).and_return(false)
        #assigns(:success).should == false
        post :merge, {:current => '1', :merge => nil}
        flash[:notice].should == 'sucks'
        response.should redirect_to '/admin/content'
      end
    end
  end
  
  
end
