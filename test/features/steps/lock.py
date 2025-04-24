from behave import *

import os
import tempfile
import subprocess

def assert_equal(a, b):
    if a != b:
        raise AssertionError(f'{str(a)} != {str(b)}')

@given('a git repo {repo}')
def step_impl(context, repo):
    if not hasattr(context, 'repos'):
        context.repos = {}
    context.repos[repo] = tempfile.TemporaryDirectory()
    cwd = context.repos[repo].name
    subprocess.check_output(['git', 'init'], cwd=cwd)
    subprocess.check_output(['git', 'commit', '--allow-empty', '-m', 'Initial commit'], cwd=cwd)
    subprocess.check_output(['git', 'checkout', '-b', 'tmp'], cwd=cwd)

@given('we have cloned {repo} to {clone}')
def step_impl(context, repo, clone):
    context.repos[clone] = tempfile.TemporaryDirectory()
    cwd = context.repos[clone].name
    subprocess.check_output(['git', 'clone', context.repos[repo].name, '-b', 'master', '.'], cwd=cwd)

@given('{repo} has initialised git-lock')
def step_impl(context, repo):
    cwd = context.repos[repo].name
    subprocess.check_output(['git', 'lock', 'show'], cwd=cwd)

@given('{repo} is configured with {option} {value}')
def step_impl(context, repo, option, value):
    cwd = context.repos[repo].name
    subprocess.check_output(['git', 'config', option, value], cwd=context.repos[repo].name)

@given('we create file {path} in {repo}')
def step_impl(context, path, repo):
    cwd = context.repos[repo].name
    subprocess.check_output(['touch', path], cwd=cwd)

@given('we add file {path} in {repo}')
def step_impl(context, path, repo):
    cwd = context.repos[repo].name
    subprocess.check_output(['git', 'add', path], cwd=cwd)

@given('we commit {repo} with message {msg}')
def step_impl(context, repo, msg):
    cwd = context.repos[repo].name
    subprocess.check_output(['git', 'commit', '-m', msg], cwd=cwd)

@given('we push {repo}')
def step_impl(context, repo):
    cwd = context.repos[repo].name
    subprocess.check_output(['git', 'push'], cwd=cwd)

@when('we lock {repo} {path}')
def step_impl(context, repo, path):
    cwd = context.repos[repo].name
    subprocess.check_output(['git', 'lock', 'acquire', path], cwd=cwd)

@when('we release {repo} {path}')
def step_impl(context, repo, path):
    cwd = context.repos[repo].name
    subprocess.check_output(['git', 'lock', 'release', path], cwd=cwd)

@then('{repo} {path} check succeeds')
def step_impl(context, path, repo):
    cwd = context.repos[repo].name
    subprocess.check_output(['git', 'lock', 'check', path], cwd=cwd)

@then('{repo} {path} check fails')
def step_impl(context, path, repo):
    cwd = context.repos[repo].name
    p = subprocess.run(['git', 'lock', 'check', path], cwd=cwd)
    assert p.returncode != 0

@then('{repo} {path} is not locked')
def step_impl(context, path, repo):
    cwd = context.repos[repo].name
    p = subprocess.run(['git', 'lock', 'owner', path], cwd=cwd, stdout=subprocess.PIPE, encoding='utf-8')
    assert_equal(p.stdout.strip(), '')

@then('{repo} {path} is locked by {name}')
def step_impl(context, path, repo, name):
    cwd = context.repos[repo].name
    p = subprocess.run(['git', 'lock', 'owner', path], cwd=cwd, stdout=subprocess.PIPE, encoding='utf-8')
    assert_equal(p.stdout.strip(), name)
