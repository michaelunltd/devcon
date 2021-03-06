require 'spec_helper'

describe 'Articles pages' do

  subject { page }

  describe 'for anonymous users' do

    describe 'in the index page' do

      before { visit articles_path }

      it { should have_page_title 'Articles' }
      it { should have_page_heading 'Articles' }
      it { should_not have_link 'New article' }
      it { should_not have_link 'Edit' }
      it { should_not have_link 'Destroy' }
    end

    describe 'in the show page' do

      before do
        @article = Fabricate(:article)
        visit article_path(@article)
      end

      it { should have_page_title @article.title }
      it { should have_page_heading @article.title }
      it 'should have the link of the categories'
      # it { should have_link @article.categories.first.name }
      it { should have_link 'Back to articles' }
      it { should_not have_link 'Edit' }
      it { should_not have_link 'Destroy' }

      describe 'comments section' do
        it { should have_content 'Comments' }
        it { should have_content 'You must be logged in to comment' }
        it { should_not have_button 'Submit comment' }
      end
    end

    describe 'in the new page' do

      before { visit new_article_path }

      it { should have_error_message 'Access denied' }
      it { should have_page_title '' }
      it { should have_page_heading 'Developers Connect' }
    end

    describe 'in the edit page' do

      before do
        @article = Fabricate(:article)
        visit edit_article_path(@article)
      end

      it { should have_error_message 'Access denied' }
      it { should have_page_title '' }
      it { should have_page_heading 'Developers Connect' }
    end
  end

  describe 'for signed-in users' do

    describe 'as a regular user' do

      before do
        @user = Fabricate(:user)
        visit new_user_session_path
        capybara_signin(@user)
      end

      describe 'in the index page' do

        before { visit articles_path }

        it { should have_page_title 'Articles' }
        it { should have_page_heading 'Articles' }
        it { should_not have_link 'New article' }
        it { should_not have_link 'Edit' }
        it { should_not have_link 'Destroy' }
      end

      describe 'in the show page' do

        before do
          @article = Fabricate(:article)
          visit article_path(@article)
        end

        it { should have_page_title @article.title }
        it { should have_page_heading @article.title }
        it { should have_link 'Back to articles' }
        it { should_not have_link 'Edit' }
        it { should_not have_link 'Destroy' }

        describe 'comments section' do
          it { should have_content 'Comments' }
          it { should_not have_content 'You must be logged in to comment' }

          describe 'on posting comments' do
            before do
              fill_in 'Comment', :with => 'Foobar'
              click_button 'Submit comment'
            end

            it { should have_content 'Foobar' }
            it { should have_content @user.name }
          end
        end
      end

      describe 'in the new page' do

        before { visit new_article_path }

        it { should have_error_message 'Access denied' }
        it { should have_page_title '' }
        it { should have_page_heading 'Developers Connect' }
      end

      describe 'in the edit page' do

        before do
          @article = Fabricate(:article)
          visit edit_article_path(@article)
        end

        it { should have_error_message 'Access denied' }
        it { should have_page_title '' }
        it { should have_page_heading 'Developers Connect' }
      end
    end

    describe 'as an author' do

      before do
        @author = Fabricate(:author)
        visit new_user_session_path
        capybara_signin(@author)
      end

      describe 'in the index page' do

        before { visit articles_path }

        it { should have_page_title 'Articles' }
        it { should have_page_heading 'Articles' }
        it { should have_link 'New article' }

        describe 'when author has an article in the list' do

          before do
            @article = Fabricate(:article, :author => @author)
            visit articles_path
          end

          it { should have_link 'Edit', :href => edit_article_path(@article) }
          it { should have_link 'Destroy', :method => :delete, :href => article_path(@article) }
        end
      end

      describe 'in the show page' do

        before do
          @article = Fabricate(:article, :author => @author)
          # binding.pry
          visit article_path(@article)
          # save_and_open_page
        end

        it { should have_page_title @article.title }
        it { should have_page_heading @article.title }
        it { should have_link 'Back to articles' }

        describe 'when author is the one who made the article' do

          it { should have_link 'Edit', :href => edit_article_path(@article) }
          it { should have_link 'Destroy', :method => :delete, :href => article_path(@article) }
        end

        describe 'when author is not the one who made the article' do

          before do
            @other_author = Fabricate(:author)
            click_link 'Sign out'
            click_link 'Sign in'
            capybara_signin(@other_author)
            visit article_path(@article)
          end

          it { should_not have_link 'Edit', :href => edit_article_path(@article) }
          it { should_not have_link 'Destroy', :method => :delete, :href => article_path(@article) }
        end
      end

      describe 'on creating articles' do

        before do
          @category = Fabricate(:category)
          visit new_article_path
        end

        it { should have_page_title 'New article' }
        it { should have_page_heading 'New article' }
        it { should have_link 'Back to articles' }

        describe 'with invalid information' do

          it 'should not create an article' do
            
            expect { click_button 'Create' }.should_not change(Article, :count)
          end

          describe 'on error messages' do

            before { click_button 'Create' }

            it { should have_error_message 'errors' }
          end
        end

        describe 'with valid information' do

          before do
            fill_in 'Title', :with => 'Hello World'
            fill_in 'Content', :with => 'Lorem Ipsum'
            check @category.name
          end

          it 'should create an article' do
            
            expect { click_button 'Create' }.should change(Article, :count).by(1)
          end

          describe 'on success messages' do
            
            before { click_button 'Create' }

            it { should have_success_message 'published' }
          end
        end
      end

      describe 'in the edit page' do
        before do
          @category = Fabricate(:category)
          @article = Fabricate(:article, :author => @author)
          visit edit_article_path(@article)
        end

        it { should have_page_title 'Edit article' }
        it { should have_page_heading 'Edit article' }
        it { should have_link 'Back to articles' }

        describe 'with invalid information' do

          before do
            fill_in 'Title', :with => ' '
            fill_in 'Content', :with => ' '
            click_button 'Update'
          end

          it { should have_error_message 'errors' }
        end

        describe 'with valid information' do

          before do
            fill_in 'Content', :with => 'foobar'
            uncheck @category.name
            click_button 'Update'
          end

          it { should have_success_message 'updated' }
        end
      end

      describe 'on destroying articles' do

        it 'should destroy the article' do
          pending 'check if the number of articles decrease'
          expect { delete article_path(@article) }.should change(Article, :count).by(-1)
        end

        describe 'on notice messages' do
          
          it 'should have a notice message' do
            pending 'check for a notice message'
            before { delete article_path(@article) }

            it { should have_notice_message 'destroyed' }
          end
        end
      end
    end
  end
end
