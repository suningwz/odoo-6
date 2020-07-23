# Part of Odoo. See LICENSE file for full copyright and licensing details.
{
    'name': 'Odoo session timeout',
    'version': '1.0',
    'category': 'Tools',
    'description': """
        Auto logout if user don't have any activity (after 300 secs)on opened tab.
        We need to improve this module so user can config timeout constant instead of fixed to 300 secs
    """,
    'depends' : ['web'],
    'demo': [],
    'data': [
        'views/template.xml',
    ],
}
