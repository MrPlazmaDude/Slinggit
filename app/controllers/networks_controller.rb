class NetworksController < ApplicationController
  before_filter :signed_in_user

  def index
    @api_accounts = ApiAccount.all(:conditions => ['status != ? AND user_id = ?', STATUS_DELETED, current_user.id])
  end

  def set_primary_account
    #this may seem a bit much but we only want to set the new primary if we can make sure and unset the other if there is one
    #so that there arent conflicts... if there isnt one to begin with, we just save the new one and return success
    if request.post?
      if not params[:api_account_id].blank?
        api_account_id = params[:api_account_id].split('_').last
        if new_primary_account = ApiAccount.first(:conditions => ['user_id = ? AND id = ?', current_user.id, api_account_id.to_i], :select => 'id,status,api_source')
          if old_primary_account = ApiAccount.first(:conditions => ['user_id = ? AND status = ? AND api_source = ?', current_user.id, STATUS_PRIMARY, new_primary_account.api_source], :select => 'id,status')
            success = remove_primary_status_from_account(old_primary_account)
            if success
              success = add_primary_status_to_account(new_primary_account)
              if success
                render :text => "#{api_account_id}_#{old_primary_account.id}", :status => 200
              end
            else
              render :text => 'error', :status => 500
            end
          else
            success = add_primary_status_to_account(new_primary_account)
            if success
              render :text => "#{api_account_id}", :status => 200
            else
              render :text => 'error', :status => 500
            end
          end
        else
          render :text => 'error', :status => 500
        end
      else
        render :text => 'error', :status => 500
      end
    else
      render :text => 'error', :status => 500
    end
  end

  def remove_primary_status_from_account(api_account)
    api_account.status = STATUS_ACTIVE
    if api_account.save
      return true
    else
      return false
    end
  end

  def add_primary_status_to_account(api_account)
    api_account.status = STATUS_PRIMARY
    if api_account.save
      return true
    else
      return false
    end
  end

  def delete_account
    if request.post?
      if not params[:api_account_id].blank?
        api_account_id = params[:api_account_id].split('_').last
        if api_account = ApiAccount.first(:conditions => ['id = ? AND user_id = ?', api_account_id, current_user.id])
          success, result = delete_api_account(api_account)
          if success
            render :text => "#{api_account_id}", :status => 200
          else
            render :text => 'error', :status => 500
          end
        else
          render :text => 'error', :status => 500
        end
      else
        render :text => 'error', :status => 500
      end
    else
      render :text => 'error', :status => 500
    end
  end

  def add_api_account
    case params[:id]
      when 'twitter'
        setup_twitter_call
      when 'facebook'
        setup_facebook_call(facebook_callback_url, 'publish_stream')
    end
  end

end
