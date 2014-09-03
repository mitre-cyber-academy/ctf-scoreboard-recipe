RailsAdmin.config do |config|

  config.current_user_method { current_user } #auto-generated
  
  config.label_methods << :email
  
  config.authorize_with do
    redirect_to root_path unless current_user.admin?
  end
  
  config.model User do
    visible false
  end
  
  config.model FeedItem do
    visible false
  end
  
  config.model Key do
    list do
      fields :player, :name, :updated_at
    end
  end
  
  config.model Admin do
    edit do
      field :email do
        label "Login"
      end
      fields :password, :password_confirmation
    end
    list do
      field :id
      field :email do
        label "Login"
      end
      fields :current_sign_in_at, :locked_at
    end
  end
  
  config.model Player do
    edit do
      field :email do
        label "Login"
      end
      field :city do
        label "Location"
      end
      fields :password, :password_confirmation, :display_name, :tags, :game, :city, :affiliation
    end
    list do
      fields :id, :display_name, :current_sign_in_at, :locked_at, :game
    end
  end
  
  config.model Game do
    list do
      fields :name, :start, :stop
    end
    edit do
      fields :name, :start, :stop, :irc
      field :tos do
        label "Terms of Service"
      end
    end
  end
  
  config.model Category do
    list do
      fields :name, :game
    end
    edit do
      fields :name, :game
    end
  end
  
  config.model Challenge do
    list do
      fields :name, :point_value, :state, :category
    end
  end
  
  config.model SolvedChallenge do
    list do
      fields :player, :challenge, :created_at
    end
    edit do
      fields :player, :challenge, :created_at
    end
  end
  
  config.model ScoreAdjustment do
    list do
      fields :player, :point_value
      field :text do
        label "Comments"
      end
      field :created_at
    end
    edit do
      fields :player, :point_value
      field :text do
        label "Comments"
      end
    end
  end
  
  config.model Achievement do
    list do
      field :text do
        label "Name"
      end
      fields :player, :created_at
    end
    edit do
      field :text do
        label "Name"
      end
      fields :player
    end
  end
  
  config.model Message do
    edit do
      fields :title, :game, :text
    end
    list do
      fields :title, :game, :created_at
    end
  end
  
  config.model SubmittedFlag do
    list do
      fields :player, :challenge, :text, :created_at
    end
  end
  
end
