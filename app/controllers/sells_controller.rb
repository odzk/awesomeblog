class SellsController < ApplicationController
  before_action :logged_in_user, only: [:index, :show, :new, :create, :edit, :edit, :update, :delete]
  before_action :correct_user, only: [:edit, :update, :delete]

  
  
  
  
  
  helper_method :sort_column, :sort_direction
  #helper使えるように

  def index
    
    # @sells = Sell.all.order(sort_column + ': :' + sort_direction).paginate(page: params[:page])

    if params[:sell]
      #filter 
      @sells = Sell.where(maker: params[:sell][:maker].downcase)
    else
      #show all
      @sells = Sell.all.order(sort_column + ': :' + sort_direction).paginate(page: params[:page])
    end
    
    #@sells =Sell.paginate(page: params[:page]) 
    #@sells = Sell.order(params[:sort] + ': :' + params[:direction])
    #@sells = Sell.order(params[:sort])
    #.orderが並び替え
  end
  
  
  
  def home
  @sell = Sell.find(params[:id])
  @division = @sell.price / @sell.number
  @details = Details.all
  end
  

  def show
    @sell = Sell.find(params[:id])
    
    
  # #  @sell = current_user.sells.find(sell_params)
  #   @division = @sell.price / @sell.number
  #   #@details = Details.all
  #   # @detail = Sell.detail.find(params[:id])
    
    if @sell.content_type == "パチンコ"
      @embeded_place = 'sells/detail'
    elsif @sell.content_type == "スロット"
      @embeded_place = 'sells/detail2'
    elsif @sell.content_type == "その他"
      @embeded_place = 'sells/detail3'
    end
    
  end
  
  # def show_slot
  #   @sell = Sell.find(params[:id])
  # end
  
  # def show_extra
  #   @sell = Sell.find(params[:id])
  # end
  

  def new
    session[:pachinko] =  "パチンコ"
    # @cylinder = "無し"
    # @pachinko = "パチンコ"
    @sell = Sell.new
    store_location
  end
  
  def slot
    session[:pachinko] =  "スロット"
    # @type_machine = "無し"
    # @pachinko = "スロット"
    @sell = Sell.new
    store_location
  end
  
  def extra
    session[:pachinko] =  "その他"
    # @cylinder = "無し"
    # @maker = "無し"
    # @remnant = "無し"
    # @pachinko = "その他"
    @sell = Sell.new
    store_location
  end
  
  def edit
    @sell = Sell.find(params[:id])
  
  end
  
  def create
     @sell = current_user.sells.build(sell_params)
     #@sell = Sell.build(sell_params)
     if @sell.save
       
       @sell.update(:content_type => session[:pachinko])
       
       session.delete(:pachinko)
       
      # unless @maker.blank?
      #   @maker.update(:maker => @maker)
      # end
       
      # unless @remnant.blank?
      #   @remnant.update(:remnant => @remnant)
      # end
       
      # unless @type_machine.blank?
      #   @type_machine.update(:type_machine => @type_machine)
      # end
       
      # unless @cylinder.blank?
      #   @cylinder.update(:cylinder => @cylinder)
      # end
       
       flash[:success] = "投稿が完了しました！"
       redirect_to root_url
     else
       @sell = []
       flash[:danger] = "未入力項目があります。"
       redirect_back_or(new_sell_path)

     end
  end





  def update
    @sell = Sell.find(params[:id])
    if @sell.update(sell_params) #通常、セキュリティ入れる
      redirect_to root_url #通常、redirect_to ★url_path
    else
      render 'edit'
    end
  end
  
  # def destroy
  #   @sell = Sell.find(params[:id])
  #   @sell.destroy
  #     redirect_to root_url
  # end
  
  def destroy
    # @micropost = current_user.micropost.find(params[:id])
    # ここに直で書いてしまうとバリデーションが効かない。
    
    @sell.destroy
    flash[:success] = "投稿は削除されました"
    
    # redirect_to users_path
    #これだと、ユーザーページでもトップに飛んでしまう。
    
    redirect_to request.referrer || root_url
    #どのページでもリダイレクトするためのコピペテンプレ。
    #request.referrerメソッド
    
  end
  
  
  # def detail
    
  # #   # @sell = Sell.find(params[:id])
  # #   # @user = User.find(params[:id])
  # #   # @details = User.all

  #   # @sell  = Sell.find(params[:id])
  #   # @sells = @sell.following.paginate(page: params[:page])
  #   # render 'show_follow'
  # end
    

  def make_safe
    @sell = Sell.find(params[:id])
    @safe = Safe.new
    
    @current = current_user.id
    @seller = @sell.user_id
    @one = "one"
    
    @safe.update(:sell_id => @sell.id)
    @safe.update(:buyer_id => @current)
    @safe.update(:seller_id => @seller)
    @safe.update(:status => @one)

  end
    

  private
  
  
   def correct_user
     @sell = current_user.sells.find_by(id:params[:id])
     redirect_to root_url if @sell.nil?
   end
 

  def sell_params
    params.require(:sell).permit(:user_id, :sell_id, :name, :maker, :number, :status, :place, :type_machine, :price, :removal_date, :remnant, :stage, :condition, :remarks)
  end

  def sort_column
      Sell.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
  end
  
  



  
  
end