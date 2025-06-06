module Avo
  module TestHelpers
    include WaitForLoaded

    # Finds the wrapper element on the index view for the given field id and type, and associated with the given record id
    # Example usage:
    #   index_field_wrapper(id: "name", type: "text", record_id: 2)
    #   index_field_wrapper(id: "name", record_id: 2)
    def index_field_wrapper(id:, record_id:, type: nil)
      base_data = "#{row(record_id)} [data-field-id='#{id}']"

      if type.present?
        find("#{base_data}[data-resource-index-target='#{wrapper_name_for(id: id, type: type)}']")
      else
        find(base_data)
      end
    end

    # Finds the wrapper element on the index grid view type for the given record id
    # Example usage:
    #   grid_field_wrapper(record_id: 5)
    def grid_field_wrapper(record_id:)
      find("[data-component-name='avo/index/grid_item_component'][data-resource-id='#{record_id}']")
    end

    # Finds the wrapper element on the show view for the given field id and type
    # Example usage:
    #   show_field_wrapper(id: "name", type: "text")
    #   show_field_wrapper(id: "name")
    def show_field_wrapper(id:, type: nil)
      base_data = "[data-panel-id='main'] [data-field-id='#{id}']"

      if type.present?
        find("#{base_data}[data-resource-show-target='#{wrapper_name_for(id: id, type: type)}']")
      else
        find(base_data)
      end
    end

    # Finds the table on the show view for the given has_many field id and view
    # Example usage:
    #   has_many_field_wrapper(id: :users)
    #   has_many_field_wrapper(id: :users, view: :edit)
    def has_many_field_wrapper(id:, view: :show)
      related_field_context(id: id, relation: :has_many, view: view)
    end

    # Finds the table on the show view for the given has_and_belongs_to_many field id and view
    # Example usage:
    #   has_and_belongs_to_many_field_wrapper(id: :users)
    #   has_and_belongs_to_many_field_wrapper(id: :users, view: :edit)
    def has_and_belongs_to_many_field_wrapper(id:, view: :show)
      related_field_context(id: id, relation: :has_and_belongs_to_many, view: view)
    end

    # Finds the table on the show view for the given has_one field id and view
    # Example usage:
    #   has_one_field_wrapper(id: :users)
    #   has_one_field_wrapper(id: :users, view: :edit)
    def has_one_field_wrapper(id:, view: :show)
      related_field_context(id: id, relation: :has_one, view: view)
    end

    # Finds the label element on the index view for the given field id
    # Example usage:
    #   index_field_label(id: "name")
    def index_field_label(id:)
      find("[data-component-name='avo/partials/table_header'] [data-table-header-field-id='#{id}']").text
    end

    # Finds the label element on the show view for the given field id
    # Example usage:
    #   show_field_label(id: "name")
    def show_field_label(id:)
      within(show_field_wrapper(id: id)) { find("[data-slot='label']").text }
    end

    # Finds the value element on the index view for the given field id
    # Example usage:
    #   index_field_value(id: "name", record_id: 2)
    def index_field_value(id:, record_id:, type: nil)
      index_field_wrapper(id: id, record_id: record_id, type: type).text
    end

    # Finds the value element on the show view for the given field id
    # Example usage:
    #   show_field_value(id: "name")
    def show_field_value(id:, type: nil)
      within(show_field_wrapper(id: id, type: type)) { find("[data-slot='value']").text }
    end

    def empty_dash
      "—"
    end

    # Example usage:
    #   click_resource_search_input # opens the first search box on the given page
    #   opens the search box for the "users" resource
    #   within(has_and_belongs_to_many_field_wrapper(id: :users)) {
    #     click_resource_search_input
    #     write_in_search("Bob")
    #   }
    def click_resource_search_input
      first("[data-search-resource]:not([data-search-resource='global'])").click
      wait_for_search_loaded
    end

    def click_global_search_input
      page.find(:xpath, "//*[contains(@class, 'global-search')]").click
      wait_for_search_loaded
    end

    # Should use the click_global_search_input or click_resource_search_input method to open the search box first.
    # Example usage:
    #   open_search_box(:users)
    #   within(has_and_belongs_to_many_field_wrapper(id: :users)) {
    #     click_resource_search_input # opens the search box for the "users" resource
    #     write_in_search("Bob")
    #   }
    def write_in_search(input)
      # Use xpath to find outside of within context if any
      find(:xpath, "//input[@class='aa-Input']").set(input)
      wait_for_search_loaded
    end

    # Should use the click_global_search_input or click_resource_search_input method to open the search box first and optionaly write_in_search.
    # Example usage:
    #   open_search_box(:users) # opens the search box for the "users" resource
    #   write_in_search("John Doe")
    #   select_first_result_in_search
    def select_first_result_in_search
      type :down, :enter
    rescue
      find(".aa-Input").send_keys :arrow_down
      find(".aa-Input").send_keys :enter
    ensure
      wait_for_search_loaded
    end

    # Save a record and wait for the page to load
    # For most cases `.click` works
    # Sometimes other element may be overlapping the button so the `.trigger("click")` solves the issue
    # Trigger can't be used by default because it breaks on some feature specs
    def save
      button = find("button.button-component", text: "Save")
      button.click
    rescue Capybara::Cuprite::MouseEventFailed
      button.trigger("click")
    ensure
      wait_for_loaded
    end

    def click_tab(tab_name = "", within_target: nil, **args)
      if within_target.present?
        within within_target do
          within find('[data-controller="tabs"] [data-tabs-target="tabSwitcher"]') do
            find_link(tab_name).trigger("click")
          end
        end
      else
        within find('[data-controller="tabs"] [data-tabs-target="tabSwitcher"]') do
          find_link(tab_name).trigger("click")
        end
      end
      wait_for_loaded
    end

    def tab_group(index = 0)
      find_all('[data-controller="tabs"]')[index]
    end

    def first_tab_group
      tab_group 0
    end

    def second_tab_group
      tab_group 1
    end

    def third_tab_group
      tab_group 3
    end

    def click_on_sidebar_item(label)
      within main_sidebar do
        click_on label
      end
    end

    def set_picker_day(date)
      find(".flatpickr-day[aria-label=\"#{date}\"]").click
      sleep 0.2
    end

    def set_picker_hour(value)
      find(".flatpickr-hour").set(value)
    end

    def set_picker_minute(value)
      find(".flatpickr-minute").set(value)
    end

    def set_picker_second(value)
      find(".flatpickr-second").set(value)
    end

    def open_picker
      text_input.click
    end

    def close_picker
      find('[data-target="title"]').trigger("click")
      sleep 0.3
    end

    # Click on the action from the panel (index and show above the table)
    # Pass list: nil to run an action outside of the list
    # Pass list: "List name" if list is not the default "Actions"
    # Example usage:
    #   open_panel_action(action_name: "Dummy action")
    #   open_panel_action(list: nil, action_name: "Release fish")
    #   open_panel_action(list: "Runnables", action_name: "Release fish")
    def open_panel_action(action_name:, list: "Actions")
      open_action(action_name: action_name, list: list, context: first("[data-target='panel-tools']"))
    end

    # Open the action from the record_id row
    # Pass list: nil to run an action outside of the list
    # Pass list: "List name" if list is not the default "Actions"
    # Example usage:
    #   open_row_action(action_name: "Dummy action")
    #   open_row_action(list: nil, action_name: "Release fish")
    #   open_row_action(list: "Runnables", action_name: "Release fish")
    def open_row_action(record_id:, action_name:, list: "Actions")
      open_action(action_name: action_name, list: list, context: row(record_id))
    end

    # Click on submit action button if dialog is open
    def run_action
      within(find("[role='dialog']")) do
        find("[data-target='submit_action']").click
      end

      wait_for_action_dialog_to_disappear
    end

    def check_select_all
      find("input[type='checkbox'][name='Select all'][data-action='input->item-select-all#toggle']").set(true)
    end

    def toggle_collapsable(section)
      find("[data-action='click->menu#triggerCollapse'][data-menu-key-param*='main_menu.#{section.underscore}'] svg").click
    end

    # Example usage:
    #   expect(add_tag(field: :tags, tag: "one")).to eq ["one"]
    #   add_tag(field: :tags, tag: "two")
    def add_tag(field:, tag:)
      # Find the input field for the specified field and click it
      find("[data-field-id='#{field}'] [data-slot='value'] [role='textbox']").click

      # Enter the specified tag into the input field
      type tag, :return
      wait_for_tag_to_appear(tag)

      # Return an array of the current tags
      tags(field: field)
    end

    # Example usage:
    #   expect(remove_tag(field: :tags, tag: "one")).to eq ["three"]
    #   remove_tag(field: :tags, tag: "one")
    def remove_tag(field:, tag:)
      # Within the specified field
      within("[data-field-id='#{field}'] [data-slot='value']") do
        # Find the tag with the specified text and click the remove button for the tag
        page.find(".tagify__tag", text: tag).find(".tagify__tag__removeBtn").click

        wait_for_tag_to_disappear(tag)
      end

      # Return an array of the current tags
      tags(field: field)
    end

    # Example usage:
    #   expect(tags(field: :tags)).to eq ["one", "two", "three"]
    #   expect(tags(field: :tags)).to eq []
    def tags(field:)
      # Find all elements with class 'tagify__tag'
      # Map the elements to text and return the array of texts
      page.all(".tagify__tag").map(&:text)
    end

    # Example usage:
    #   expect(tag_suggestions(field: :tags, input: "")).to eq ["one", "two", "three"]
    #   expect(tag_suggestions(field: :tags, input: "t")).to eq ["two", "three"]
    def tag_suggestions(field:, input:)
      # Find the input field for the specified tag field
      input_area = find("[data-field-id='#{field}'] [data-slot='value'] [role='textbox']")

      # If the input argument is present, enter it into the input field
      # Else, set input to "open" than to " " to trigger dropdown
      if input.present?
        input_area.set(input)
      else
        input_area.set("open")
        input_area.set(" ")
      end
      wait_for_tag_suggestions_to_appear

      # Find all elements with class 'tagify_dropdown_item' within the dropdown
      # Map the elements to their 'label' attribute values and return the array of labels
      page.all(".tagify__dropdown__item").map { |element| element[:label] }
    end

    def type(...)
      if page.driver.browser.respond_to?(:keyboard)
        page.driver.browser.keyboard.type(...)
      else
        page.send_keys(...)
      end
    end

    def accept_custom_alert(&block)
      block.call
      find('#turbo-confirm button[value="confirm"]').click
    end

    private

    # Returns the name of the wrapper element for the given field id and type
    def wrapper_name_for(id:, type:)
      "#{id.camelize(:lower)}#{type.camelize}Wrapper"
    end

    # Finds the context element for the related field with the given id, relation, and view
    # ex: has_and_belongs_to_many_users = related_field_context(id: :users, relation: :has_and_belongs_to_many)
    # Now on the returend element you can do:
    # first_name_wrapper = within has_and_belongs_to_many_users do
    #   index_field_wrapper(id: "first_name", type: "text", record_id: 7)
    # end
    def related_field_context(id:, relation:, view: :show)
      turbo_frame = "#{relation}_field_#{view}_#{id}"
      find("[id='#{turbo_frame}']")
    end

    def main_sidebar
      find('[data-sidebar-target="sidebar"]')
    end

    # Opens an action. If a list is provided, it will click on the list first
    # and then find the specified action name within the panel.
    # If no list is present, it will directly click on the action link.
    def open_action(action_name:, list:, context:, &block)
      within(context) do
        if list.present?
          sleep 0.1
          click_on list
          within("[data-toggle-target='panel']") do
            find("a[data-action-name='#{action_name}']").click
          end
        else
          click_link(action_name)
        end
      end

      expect(page).to have_selector(modal = "[role='dialog']")

      # Within the dialog, ensure that the action name is present
      within(find(modal)) do
        expect(page).to have_content(action_name)
      end
    end

    def row(id)
      "[data-component-name='avo/index/table_row_component'][data-resource-id='#{id}']"
    end
  end
end
