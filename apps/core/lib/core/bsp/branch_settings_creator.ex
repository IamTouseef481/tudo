defmodule Core.BSP.BranchSettingsCreator do
  @moduledoc false
  alias Core.{Services, Settings}

  @expected_work_duration "00:30:00"
  @expected_work_duration_for_home_service "01:00:00"

  def create_branch_settings(id, business_params) do
    service_radius_settings =
      Enum.reduce(
        business_params.services,
        %{home_service: [], walk_in: [], on_demand: []},
        fn service, acc ->
          case Services.get_service_by_country_service(service.country_service_id) do
            %{name: name} ->
              case service.service_type_id do
                "walk_in" ->
                  walk_in =
                    acc.walk_in ++
                      [%{radius: 30, country_service_id: service.country_service_id, name: name}]

                  Map.merge(acc, %{walk_in: walk_in})

                "on_demand" ->
                  on_demand =
                    acc.on_demand ++
                      [%{radius: 30, country_service_id: service.country_service_id, name: name}]

                  Map.merge(acc, %{on_demand: on_demand})

                "home_service" ->
                  home_service =
                    acc.home_service ++
                      [%{radius: 30, country_service_id: service.country_service_id, name: name}]

                  Map.merge(acc, %{home_service: home_service})

                _ ->
                  acc
              end

            _ ->
              acc
          end
        end
      )

    services_expected_work_duration_settings =
      Enum.reduce(
        business_params.services,
        %{home_service: [], walk_in: [], on_demand: []},
        fn service, acc ->
          case Services.get_service_by_country_service(service.country_service_id) do
            %{name: name} ->
              case service.service_type_id do
                "walk_in" ->
                  walk_in =
                    acc.walk_in ++
                      [
                        %{
                          expected_work_duration: @expected_work_duration,
                          country_service_id: service.country_service_id,
                          name: name
                        }
                      ]

                  Map.merge(acc, %{walk_in: walk_in})

                "on_demand" ->
                  on_demand =
                    acc.on_demand ++
                      [
                        %{
                          expected_work_duration: @expected_work_duration,
                          country_service_id: service.country_service_id,
                          name: name
                        }
                      ]

                  Map.merge(acc, %{on_demand: on_demand})

                "home_service" ->
                  home_service =
                    acc.home_service ++
                      [
                        %{
                          expected_work_duration: @expected_work_duration_for_home_service,
                          country_service_id: service.country_service_id,
                          name: name
                        }
                      ]

                  Map.merge(acc, %{home_service: home_service})

                _ ->
                  acc
              end

            _ ->
              acc
          end
        end
      )

    services_rates_settings =
      Enum.reduce(
        business_params.services,
        %{home_service: [], walk_in: [], on_demand: []},
        fn service, acc ->
          case Services.get_service_by_country_service(service.country_service_id) do
            %{name: name} ->
              case service.service_type_id do
                "walk_in" ->
                  walk_in =
                    acc.walk_in ++
                      [
                        %{
                          price_amount: 100.00,
                          country_service_id: service.country_service_id,
                          name: name
                        }
                      ]

                  Map.merge(acc, %{walk_in: walk_in})

                "on_demand" ->
                  on_demand =
                    acc.on_demand ++
                      [
                        %{
                          price_amount: 100.00,
                          country_service_id: service.country_service_id,
                          name: name
                        }
                      ]

                  Map.merge(acc, %{on_demand: on_demand})

                "home_service" ->
                  home_service =
                    acc.home_service ++
                      [
                        %{
                          price_amount: 100.00,
                          country_service_id: service.country_service_id,
                          name: name
                        }
                      ]

                  Map.merge(acc, %{home_service: home_service})

                _ ->
                  acc
              end

            _ ->
              acc
          end
        end
      )

    sales_tax_rate_settings =
      Enum.reduce(business_params.services, [], fn service, acc ->
        case Services.get_service_by_country_service(service.country_service_id) do
          %{name: name} ->
            result = %{
              country_service_id: service.country_service_id,
              name: name,
              service_type_id: service.service_type_id,
              tax_rate: 12,
              tax_title: "Federal/National/Central Business Tax"
            }

            acc ++ [result]

          _ ->
            acc
        end
      end)

    services_cost_estimate_settings =
      Enum.reduce(
        business_params.services,
        %{home_service: [], walk_in: [], on_demand: []},
        fn service, acc ->
          case Services.get_service_by_country_service(service.country_service_id) do
            %{name: name} ->
              case service.service_type_id do
                "walk_in" ->
                  walk_in =
                    acc.walk_in ++
                      [
                        %{
                          price_amount: 100.00,
                          final_amount: 50.00,
                          duration_minutes: 30,
                          country_service_id: service.country_service_id,
                          name: name
                        }
                      ]

                  Map.merge(acc, %{walk_in: walk_in})

                "on_demand" ->
                  on_demand =
                    acc.on_demand ++
                      [
                        %{
                          price_amount: 100.00,
                          final_amount: 50.00,
                          duration_minutes: 30,
                          country_service_id: service.country_service_id,
                          name: name
                        }
                      ]

                  Map.merge(acc, %{on_demand: on_demand})

                "home_service" ->
                  home_service =
                    acc.home_service ++
                      [
                        %{
                          price_amount: 100.00,
                          final_amount: 100.00,
                          duration_minutes: 60,
                          country_service_id: service.country_service_id,
                          name: name
                        }
                      ]

                  Map.merge(acc, %{home_service: home_service})

                _ ->
                  acc
              end

            _ ->
              acc
          end
        end
      )

    settings = [
      %{
        title: "Block future appointments",
        slug: "block_future_jobs",
        type: "branch",
        branch_id: id,
        fields: %{
          on_hold: false
        }
      },
      %{
        title: "Auto schedule appointments",
        slug: "auto_schedule",
        type: "branch",
        branch_id: id,
        fields: %{
          auto_schedule: true
        }
      },
      %{
        title: "Business Services Radius",
        slug: "services_radius",
        type: "branch",
        branch_id: id,
        fields: %{
          default_for_walk_in: 30,
          default_for_home_service: 30,
          default_for_on_demand: 30,
          same_for_all_for_walk_in: true,
          same_for_all_for_home_service: true,
          same_for_all_for_on_demand: true,
          services: service_radius_settings
        }
      },
      %{
        title: "Expected Services Duration in hrs.",
        slug: "services_expected_work_duration",
        type: "branch",
        branch_id: id,
        fields: %{
          default_for_home_service: @expected_work_duration_for_home_service,
          default_for_on_demand: @expected_work_duration,
          default_for_walk_in: @expected_work_duration,
          include_travel_home_service: false,
          include_travel_on_demand: false,
          same_for_all_for_home_service: true,
          same_for_all_for_on_demand: true,
          same_for_all_for_walk_in: true,
          services: services_expected_work_duration_settings
        }
      },
      %{
        title: "Availability",
        slug: "availability",
        type: "branch",
        branch_id: id,
        fields: %{
          custom: %{},
          default: %{
            monday: %{
              a: %{
                shift: %{
                  name: "shift",
                  description: "A",
                  from: "09:00:00",
                  to: "18:00:00"
                },
                breaks: [
                  %{
                    name: "break",
                    description: "Lunch Time",
                    from: "12:00:00",
                    to: "13:00:00"
                  }
                ]
              }
            },
            tuesday: %{
              a: %{
                shift: %{
                  name: "shift",
                  description: "A",
                  from: "09:00:00",
                  to: "18:00:00"
                },
                breaks: [
                  %{
                    name: "break",
                    description: "Lunch Time",
                    from: "12:00:00",
                    to: "13:00:00"
                  }
                ]
              }
            },
            wednesday: %{
              a: %{
                shift: %{
                  name: "shift",
                  description: "A",
                  from: "09:00:00",
                  to: "18:00:00"
                },
                breaks: [
                  %{
                    name: "break",
                    description: "Lunch Time",
                    from: "12:00:00",
                    to: "13:00:00"
                  }
                ]
              }
            },
            thursday: %{
              a: %{
                shift: %{
                  name: "shift",
                  description: "A",
                  from: "09:00:00",
                  to: "18:00:00"
                },
                breaks: [
                  %{
                    name: "break",
                    description: "Lunch Time",
                    from: "12:00:00",
                    to: "13:00:00"
                  }
                ]
              }
            },
            friday: %{
              a: %{
                shift: %{
                  name: "shift",
                  description: "A",
                  from: "09:00:00",
                  to: "18:00:00"
                },
                breaks: [
                  %{
                    name: "break",
                    description: "Lunch Time",
                    from: "12:00:00",
                    to: "13:00:00"
                  }
                ]
              }
            },
            saturday: %{
              a: %{
                shift: %{
                  name: "shift",
                  description: "A",
                  from: "09:00:00",
                  to: "18:00:00"
                },
                breaks: [
                  %{
                    name: "break",
                    description: "Lunch Time",
                    from: "12:00:00",
                    to: "13:00:00"
                  }
                ]
              }
            }
          }
        }
      },
      %{
        title: "Allow adding Discount lines on Invoice",
        slug: "allow_bsp_to_add_discount",
        type: "branch",
        branch_id: id,
        fields: %{
          add_discount: true
        }
      },
      %{
        title: "Allow adding Tax lines on Invoice",
        slug: "allow_bsp_to_add_tax",
        type: "branch",
        branch_id: id,
        fields: %{
          add_tax: true
        }
      },
      %{
        title: "Max allowed Discount %",
        slug: "max_allowed_discount",
        type: "branch",
        branch_id: id,
        fields: %{
          max_allowed_discount: %{
            max_value: 20,
            selected_value: 20,
            is_percentage: true,
            allow: true
          }
        }
      },
      %{
        title: "Max allowed Tax %",
        slug: "max_allowed_tax",
        type: "branch",
        branch_id: id,
        fields: %{
          max_allowed_tax: %{
            max_value: 20,
            selected_value: 10,
            is_percentage: true,
            allow: true
          }
        }
      },
      %{
        title: "Max allowed Invoice adjustments/ day",
        slug: "max_invoice_adjust_count",
        type: "branch",
        branch_id: id,
        fields: %{
          max_invoice_adjust_count: %{
            is_percentage: false,
            max_value: 10,
            selected_value: 5
          }
        }
      },
      %{
        title: "Services Rates",
        slug: "services_rates",
        type: "branch",
        branch_id: id,
        fields: %{
          rate_type_for_home_service: "Fixed Rate",
          rate_type_for_on_demand: "Fixed Rate",
          rate_type_for_walk_in: "Fixed Rate",
          same_for_all_for_home_service: true,
          same_for_all_for_on_demand: true,
          same_for_all_for_walk_in: true,
          common_price_for_walk_in: 100.00,
          common_price_for_on_demand: 100.00,
          common_price_for_home_service: 100.00,
          services: services_rates_settings
        }
      },
      %{
        title: "Sales Tax Rate",
        slug: "sales_tax_rate",
        type: "branch",
        branch_id: id,
        fields: %{
          national_tax_identification_number: "",
          regional_tax_identification_number: "",
          default_tax_authority: "GST",
          fiscal_year: "January - December",
          service_rate_card: [
            %{
              common_tax_title: "Federal/National/Central Business Tax",
              is_common_tax: true,
              common_tax_rate: 12.0,
              is_percentage: true,
              tax_authority: "GST",
              tax_before_discount: true,
              services: sales_tax_rate_settings
            }
          ]
        }
      },
      %{
        title: "Service Cost Estimate",
        slug: "service_cost_estimate",
        type: "branch",
        branch_id: id,
        fields: %{
          rate_type_for_home_service: "Fixed Rate",
          rate_type_for_on_demand: "Fixed Rate",
          rate_type_for_walk_in: "Fixed Rate",
          walk_in_multiplier_factor: 1.00,
          home_service_multiplier_factor: 1.00,
          on_demand_multiplier_factor: 1.00,
          is_travel_home_service: false,
          is_travel_on_demand_service: false,
          services_estimates: services_cost_estimate_settings
        }
      },
      %{
        title: "Job Request Accept Timeout",
        slug: "job_request_accept_timeout",
        type: "branch",
        branch_id: id,
        fields: %{
          timeout_seconds: 15
        }
      }
    ]

    a =
      Enum.reduce(settings, [], fn setting, acc ->
        case Settings.create_setting(setting) do
          {:ok, setting} -> [setting | acc]
          {:error, _} -> acc
          _ -> acc
        end
      end)

    {:ok, a}
  end
end
