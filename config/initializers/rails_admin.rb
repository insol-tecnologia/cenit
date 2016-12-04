require 'account'

[
  RailsAdmin::Config::Actions::DiskUsage,
  RailsAdmin::Config::Actions::SendToFlow,
  RailsAdmin::Config::Actions::SwitchNavigation,
  RailsAdmin::Config::Actions::DataType,
  RailsAdmin::Config::Actions::Filters,
  RailsAdmin::Config::Actions::Import,
  #RailsAdmin::Config::Actions::EdiExport,
  RailsAdmin::Config::Actions::ImportSchema,
  RailsAdmin::Config::Actions::DeleteAll,
  RailsAdmin::Config::Actions::TranslatorUpdate,
  RailsAdmin::Config::Actions::Convert,
  RailsAdmin::Config::Actions::Pull,
  RailsAdmin::Config::Actions::RetryTask,
  RailsAdmin::Config::Actions::DownloadFile,
  RailsAdmin::Config::Actions::ProcessFlow,
  RailsAdmin::Config::Actions::BuildGem,
  RailsAdmin::Config::Actions::Run,
  RailsAdmin::Config::Actions::Authorize,
  RailsAdmin::Config::Actions::SimpleDeleteDataType,
  RailsAdmin::Config::Actions::BulkDeleteDataType,
  RailsAdmin::Config::Actions::SimpleGenerate,
  RailsAdmin::Config::Actions::BulkGenerate,
  RailsAdmin::Config::Actions::SimpleExpand,
  RailsAdmin::Config::Actions::BulkExpand,
  RailsAdmin::Config::Actions::Records,
  RailsAdmin::Config::Actions::FilterDataType,
  RailsAdmin::Config::Actions::SwitchScheduler,
  RailsAdmin::Config::Actions::SimpleExport,
  RailsAdmin::Config::Actions::Schedule,
  RailsAdmin::Config::Actions::Submit,
  RailsAdmin::Config::Actions::Trash,
  RailsAdmin::Config::Actions::Inspect,
  RailsAdmin::Config::Actions::Copy,
  RailsAdmin::Config::Actions::Cancel,
  RailsAdmin::Config::Actions::Configure,
  RailsAdmin::Config::Actions::SimpleCross,
  RailsAdmin::Config::Actions::BulkCross,
  RailsAdmin::Config::Actions::Regist,
  RailsAdmin::Config::Actions::SharedCollectionIndex,
  RailsAdmin::Config::Actions::StoreIndex,
  RailsAdmin::Config::Actions::BulkPull,
  RailsAdmin::Config::Actions::CleanUp,
  RailsAdmin::Config::Actions::ShowRecords,
  RailsAdmin::Config::Actions::RunScript,
  RailsAdmin::Config::Actions::Play,
  RailsAdmin::Config::Actions::PullImport,
  RailsAdmin::Config::Actions::State,
  RailsAdmin::Config::Actions::Documentation,
  RailsAdmin::Config::Actions::Push,
  RailsAdmin::Config::Actions::Share,
  RailsAdmin::Config::Actions::Reinstall,
  RailsAdmin::Config::Actions::Swagger,
  RailsAdmin::Config::Actions::RestApi,
  RailsAdmin::Config::Actions::LinkDataType
].each { |a| RailsAdmin::Config::Actions.register(a) }

RailsAdmin::Config::Actions.register(:export, RailsAdmin::Config::Actions::BulkExport)

[
  RailsAdmin::Config::Fields::Types::JsonValue,
  RailsAdmin::Config::Fields::Types::JsonSchema,
  RailsAdmin::Config::Fields::Types::StorageFile,
  RailsAdmin::Config::Fields::Types::EnumEdit,
  RailsAdmin::Config::Fields::Types::Model,
  RailsAdmin::Config::Fields::Types::Record,
  RailsAdmin::Config::Fields::Types::HtmlErb,
  RailsAdmin::Config::Fields::Types::OptionalBelongsTo,
  RailsAdmin::Config::Fields::Types::Code,
  RailsAdmin::Config::Fields::Types::Tag
].each { |f| RailsAdmin::Config::Fields::Types.register(f) }

require 'rails_admin/config/fields/factories/tag'

module RailsAdmin

  module Config

    class << self

      def navigation(label, options)
        navigation_options[label.to_s] = options
      end

      def navigation_options
        @nav_options ||= {}
      end
    end
  end
end

RailsAdmin.config do |config|

  config.total_columns_width = 900

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration
  config.authenticate_with do
    warden.authenticate! scope: :user unless %w(dashboard shared_collection_index store_index index show).include?(action_name)
  end
  config.current_user_method { current_user }
  config.audit_with :mongoid_audit
  config.authorize_with :cancan

  config.excluded_models += [Setup::BaseOauthAuthorization, Setup::AwsAuthorization]

  config.actions do
    dashboard # mandatory
    # disk_usage
    shared_collection_index
    store_index
    link_data_type
    index # mandatory
    new { except [Setup::Event, Setup::DataType, Setup::Authorization, Setup::BaseOauthProvider] }
    filters
    import
    import_schema
    pull_import
    translator_update
    convert
    export
    bulk_delete
    show
    show_records
    run
    run_script
    edit
    swagger { only [Setup::Api] }
    configure
    play
    copy
    share
    simple_cross
    bulk_cross
    build_gem
    pull
    bulk_pull
    push
    download_file
    process_flow
    authorize
    simple_generate
    bulk_generate
    simple_expand
    bulk_expand
    records
    filter_data_type
    switch_navigation
    switch_scheduler
    simple_export
    schedule
    state
    retry_task
    submit
    inspect
    cancel
    regist
    reinstall
    simple_delete_data_type
    bulk_delete_data_type
    delete
    trash
    clean_up
    #show_in_app
    send_to_flow
    delete_all
    data_type
    #history_index
    history_show do
      only do
        [
          Setup::Algorithm,
          Setup::Connection,
          Setup::PlainWebhook,
          Setup::Operation,
          Setup::Resource,
          Setup::Translator,
          Setup::Flow,
          Setup::OauthClient,
          Setup::Oauth2Scope,
          Setup::Snippet
        ] +
          Setup::DataType.class_hierarchy +
          Setup::Validator.class_hierarchy +
          Setup::BaseOauthProvider.class_hierarchy
      end
      visible { only.include?((obj = bindings[:object]).class) && obj.try(:shared?) }
    end
    rest_api
    documentation
  end

  config.navigation 'Collections', icon: 'fa fa-cubes'
  config.navigation 'Definitions', icon: 'fa fa-puzzle-piece'
  config.navigation 'Connectors', icon: 'fa fa-plug'
  config.navigation 'Security', icon: 'fa fa-shield'
  config.navigation 'Compute', icon: 'fa fa-cog'
  config.navigation 'Transformations', icon: 'fa fa-random'
  config.navigation 'Workflows', icon: 'fa fa-cogs'
  config.navigation 'Monitors', icon: 'fa fa-heartbeat'
  config.navigation 'Configuration', icon: 'fa fa-sliders'
  config.navigation 'Administration', icon: 'fa fa-user-secret'
end
