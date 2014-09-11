module VagrantPlugins
  module Linode
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :token
      attr_accessor :distribution
      attr_accessor :datacenter
      attr_accessor :plan
      attr_accessor :paymentterm
      attr_accessor :private_networking
      attr_accessor :ca_path
      attr_accessor :ssh_key_name
      attr_accessor :setup

      alias_method :setup?, :setup

      def initialize
        @token              = UNSET_VALUE
        @distribution       = UNSET_VALUE
        @datacenter         = UNSET_VALUE
        @plan               = UNSET_VALUE
        @paymentterm        = UNSET_VALUE
        @private_networking = UNSET_VALUE
        @ca_path            = UNSET_VALUE
        @ssh_key_name       = UNSET_VALUE
        @setup              = UNSET_VALUE
      end

      def finalize!
        @token              = ENV['LINODE_TOKEN'] if @token == UNSET_VALUE
        @distribution       = 'Ubuntu 14.04 LTS' if @distribution == UNSET_VALUE
        @datacenter         = 'dallas' if @datacenter == UNSET_VALUE
        @plan               = 'Linode 1024' if @plan == UNSET_VALUE
        @paymentterm        = '1' if @paymentterm == UNSET_VALUE
        @private_networking = false if @private_networking == UNSET_VALUE
        @ca_path            = nil if @ca_path == UNSET_VALUE
        @ssh_key_name       = 'Vagrant' if @ssh_key_name == UNSET_VALUE
        @setup              = true if @setup == UNSET_VALUE
      end

      def validate(machine)
        errors = []
        errors << I18n.t('vagrant_linode.config.token') if !@token

        key = machine.config.ssh.private_key_path
        key = key[0] if key.is_a?(Array)
        if !key
          errors << I18n.t('vagrant_linode.config.private_key')
        elsif !File.file?(File.expand_path("#{key}.pub", machine.env.root_path))
          errors << I18n.t('vagrant_linode.config.public_key', {
            :key => "#{key}.pub"
          })
        end

        { 'Linode Provider' => errors }
      end
    end
  end
end