#!/usr/bin/env ruby

require 'YAML'

sgkey = ''
sg = YAML.load_file(ARGV[0])

sg.each_key do |key|
  sgkey = key
end


cidrList = YAML.load_file(ARGV[1])

unless sg[sgkey]['Properties'].has_key?('SecurityGroupIngress')
  sg[sgkey]['Properties']['SecurityGroupIngress'] = Array.new
end
unless sg[sgkey]['Properties'].has_key?('SecurityGroupEgress')
  sg[sgkey]['Properties']['SecurityGroupEgress'] = Array.new
end

if cidrList.has_key?("SecurityGroupIngress")
  cidrList["SecurityGroupIngress"].each do |rule|
    ingress = Hash.new
    rule.each_key do |key|
      unless key == "CidrList"
        ingress[key] = rule[key]
      end
    end
    rule["CidrList"].each do |cidr|
      rule_hash = Hash.new
      ingress.each do |key, value|
        rule_hash[key] = value
      end

      rule_hash['CidrIp'] = cidr
      sg[sgkey]['Properties']['SecurityGroupIngress'] << rule_hash
      # myArray[count] = Hash.new
      # myArray[count] = rule_hash

    end
  end

end

if cidrList.has_key?("SecurityGroupEgress")
  cidrList["SecurityGroupEgress"].each do |rule|
    ingress = Hash.new
    rule.each_key do |key|
      unless key == "CidrList"
        ingress[key] = rule[key]
      end
    end
    rule["CidrList"].each do |cidr|
      rule_hash = Hash.new
      ingress.each do |key, value|
        rule_hash[key] = value
      end

      rule_hash['CidrIp'] = cidr
      sg[sgkey]['Properties']['SecurityGroupEgress'] << rule_hash
      # myArray[count] = Hash.new
      # myArray[count] = rule_hash

    end
  end

end

puts sg.to_yaml


