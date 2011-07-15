def dns_providers
  {
    AWS       => {
      :mocked => false
    },
    Bluebox   => {
      :mocked => false,
      :zone_attributes => {
        :ttl => 60
      }
    },
    Linode    => {
      :mocked => false,
      :zone_attributes => {
        :email => 'fog@example.com'
      }
    },
    Slicehost => {
      :mocked => false
    },
    Zerigo    => {
      :mocked => false
    },
    Dynect    => {
      :mocked => false
    },
    DNSimple  => {
      :mocked => false
    },
    DNSMadeEasy  => {
      :mocked => false
    }
  }
end

def generate_unique_domain( with_trailing_dot = false)
  #get time (with 1/100th of sec accuracy)
  #want unique domain name and if provider is fast, this can be called more than once per second
  time= (Time.now.to_f * 100).to_i
  domain = 'test-' + time.to_s + '.com'
  if with_trailing_dot
    domain+= '.'
  end

  domain
end