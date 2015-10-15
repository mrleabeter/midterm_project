# Homepage (Root path)
get '/' do
  if session[:user_id]
    redirect '/user/logged_in'
  else
    erb :index
  end
end

get '/user/signup_successful'do
  erb :'user/signup_successful'
end

get '/user/login' do
  erb :'user/login'
end

get '/users/logout' do
  session[:user_id] = nil
  redirect '/'
end

get '/user/:id' do
  erb :'user/logged_in'
end

post '/' do
  @user = User.new(
    username:   params[:username].downcase,
    email: params[:email],
    password:  params[:password],
    password_confirmation: params[:password_confirmation]
  )
  @user.save

  existing_company = Company.find_by(company_name: params[:company_name])
  if existing_company != nil
    @company = existing_company
  else
    @company = Company.new(
      company_name:   params[:company_name]
    )
    @company.save
  end
  @company.save

  @discount = Discount.new(
    company_id: @company.id,
    discount_percent:  params[:discount_percent],
    user_id: @user.id
  )
  @discount.save

  restriction_description = params[:description]
  if  restriction_description != "" || restriction_description != "none"
    @restriction = Restriction.new(
      discount_id: @discount.id,
      description:  params[:description]
    )
    @restriction.save
  end

  if @user.save && @company.save && @discount.save
    redirect '/user/signup_successful'
  else
    erb :index
  end
end

post '/user/login' do
  user = User.find_by(
    username: params[:username].downcase,
    password: params[:password]
  )
  if user
    session[:user_id] = user.id
    redirect '/user/logged_in'
  else
    erb :'user/login'
  end
end
