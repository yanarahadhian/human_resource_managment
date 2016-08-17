class HoldingCompaniesController < ApplicationController
  ssl_required
  # GET /holding_companies
  # GET /holding_companies.xml
  before_filter :login_required
  layout 'application2'

  def index
    @holding_companies = HoldingCompany.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @holding_companies }
    end
  end

  # GET /holding_companies/1
  # GET /holding_companies/1.xml
  def show
    @holding_company = HoldingCompany.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @holding_company }
    end
  end

  # GET /holding_companies/new
  # GET /holding_companies/new.xml
  def new
    @holding_company = HoldingCompany.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @holding_company }
    end
  end

  # GET /holding_companies/1/edit
  def edit
    @holding_company = HoldingCompany.find(params[:id])
  end

  # POST /holding_companies
  # POST /holding_companies.xml
  def create
    @holding_company = HoldingCompany.new(params[:holding_company])

    respond_to do |format|
      if @holding_company.save
        flash.now[:notice] = 'Holding Company berhasil ditambah !'
        format.html { redirect_to(holding_companies_path) }
        format.xml  { render :xml => @holding_company, :status => :created, :location => @holding_company }
      else
        flash.now[:notice] = 'Holding Company tidak berhasil ditambah !'
        format.html { render :action => "new" }
        format.xml  { render :xml => @holding_company.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /holding_companies/1
  # PUT /holding_companies/1.xml
  def update
    @holding_company = HoldingCompany.find(params[:id])

    respond_to do |format|
      if @holding_company.update_attributes(params[:holding_company])
        flash.now[:notice] = 'Holding Company berhasil diubah !'
        format.html { redirect_to(holding_companies_path) }
        format.xml  { head :ok }
      else
        flash.now[:notice] = 'Holding Company tidak berhasil diubah !'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @holding_company.errors, :status => :unprocessable_entity }
      end
    end
  end

end
